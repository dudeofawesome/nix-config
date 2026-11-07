# Hourly restic backup of the SSD's non-reproducible state into the storage pool.
#
# The OS and the nix store rebuild from this flake; what doesn't is service
# state under /var/lib, home directories and the host SSH key (also the host's
# sops age key). restic backs those up into a repository on the pool, where the
# offsite disks then carry it away. Each run first takes read-only bcachefs
# snapshots of the root and home subvolumes and backs up from those, so every
# backup is one consistent point in time of a live system.
#
# Container and k3s state is excluded: large, churny and rebuildable.
#
# Restore: `restic -r /storage/backups/soto-ssd --password-file <file> snapshots`
# then `restic … restore latest --target /` (paths are stored as they appear
# under the snapshot directory, e.g. /.ssd-backup/root/var/lib).
{ config, pkgs, ... }:
let
  snapshotDir = "/.ssd-backup";
  bcachefs = "${config.boot.bcachefs.package}/bin/bcachefs";
in
{
  sops.secrets."hosts/nixos/soto-server/restic_password" = {
    sopsFile = ./secrets.yaml;
  };

  services.restic.backups.soto-ssd = {
    repository = "/storage/backups/soto-ssd";
    passwordFile = config.sops.secrets."hosts/nixos/soto-server/restic_password".path;
    initialize = true;

    backupPrepareCommand = ''
      rm -rf ${snapshotDir}
      mkdir -p ${snapshotDir}
      ${bcachefs} subvolume snapshot --read-only / ${snapshotDir}/root
      ${bcachefs} subvolume snapshot --read-only /home ${snapshotDir}/home
    '';
    backupCleanupCommand = ''
      ${bcachefs} subvolume delete ${snapshotDir}/home ${snapshotDir}/root || true
      rm -rf ${snapshotDir}
    '';

    paths = [
      "${snapshotDir}/root/var/lib"
      "${snapshotDir}/root/etc/ssh"
      "${snapshotDir}/home"
    ];
    exclude = [
      "${snapshotDir}/root/var/lib/docker"
      "${snapshotDir}/root/var/lib/containers"
      "${snapshotDir}/root/var/lib/rancher"
      "${snapshotDir}/root/var/lib/systemd/coredump"
    ];

    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-hourly 48"
      "--keep-daily 30"
      "--keep-monthly 12"
    ];
  };

  # The repository lives on the pool; don't start before it is mounted.
  systemd.services.restic-backups-soto-ssd.unitConfig.RequiresMountsFor = [
    "/storage/backups/soto-ssd"
  ];
}
