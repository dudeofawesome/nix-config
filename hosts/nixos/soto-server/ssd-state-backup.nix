# Hourly copy of the SSD's non-reproducible state into the storage pool.
#
# The OS and the nix store rebuild from this flake; what doesn't is service
# state under /var/lib, home directories and the host SSH key (which is also
# the host's sops age key). Those are rsynced from the newest snapper snapshot
# of the root filesystem (consistent point in time) into
# /storage/backups/soto-ssd, which the offsite disks then carry away.
#
# Container and k3s state is excluded: large, churny and rebuildable.
{ pkgs, ... }:
let
  ssd-state-backup = pkgs.writeShellApplication {
    name = "ssd-state-backup";
    runtimeInputs = [
      pkgs.rsync
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      dest=/storage/backups/soto-ssd
      # Newest snapper snapshot of /, else the live filesystem.
      src=$(find /.snapshots -mindepth 2 -maxdepth 2 -name snapshot -type d 2>/dev/null | sort -V | tail -1)
      src=''${src:-/}
      echo "backing up $src -> $dest"
      rsync \
        --archive --hard-links --acls --xattrs --numeric-ids \
        --delete --delete-excluded \
        --relative \
        --exclude='/var/lib/docker/' \
        --exclude='/var/lib/containers/' \
        --exclude='/var/lib/rancher/' \
        --exclude='/var/lib/systemd/coredump/' \
        "$src/./var/lib" "$src/./home" "$src/./etc/ssh" \
        "$dest/"
      date -Is > "$dest/.last-backup"
    '';
  };
in
{
  systemd.services.ssd-state-backup = {
    description = "Copy the SSD's non-reproducible state into the storage pool";
    unitConfig.RequiresMountsFor = [ "/storage/backups/soto-ssd" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ssd-state-backup}/bin/ssd-state-backup";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.timers.ssd-state-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
  };
}
