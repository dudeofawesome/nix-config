# Offsite backup disks: single-disk ZFS pools named `backup-a` / `backup-b`.
#
# Slide one into a free bay and udev starts `offsite-backup@backup-a.service`,
# which imports the pool, replicates every `storage` dataset as raw (still
# encrypted) incremental sends, scrubs the disk, exports the pool and logs a
# completion line. Only pull the disk after the export; `journalctl -u
# 'offsite-backup@*'` shows progress and the final "complete" line.
#
# Creating a new backup disk (once, on the server, with the disk in a bay):
#   zpool create -o ashift=12 -O compression=zstd -O atime=off -O canmount=off \
#     -O mountpoint=none backup-a /dev/disk/by-id/ata-<model>_<serial>
#   zpool export backup-a
# then re-insert it (or `systemctl start offsite-backup@backup-a`).
{ config, pkgs, ... }:
let
  offsite-backup = pkgs.writeShellApplication {
    name = "offsite-backup";
    runtimeInputs = [
      config.boot.zfs.package
      pkgs.sanoid # provides syncoid
      pkgs.util-linux
      pkgs.systemd
    ];
    text = ''
      pool="$1"
      case "$pool" in
        backup-[a-z]) ;;
        *) echo "refusing to use '$pool' as an offsite pool" >&2; exit 1 ;;
      esac

      echo "importing $pool"
      zpool import -N "$pool"
      trap 'zpool export "$pool" || true' EXIT

      echo "replicating storage -> $pool/storage (raw incremental sends)"
      syncoid \
        --recursive \
        --no-sync-snap \
        --create-bookmark \
        --sendoptions=w \
        --no-privilege-elevation \
        storage "$pool/storage"

      echo "scrubbing $pool"
      zpool scrub -w "$pool"
      zpool status "$pool"

      trap - EXIT
      zpool export "$pool"
      echo "offsite backup to $pool complete; the disk can be removed"
    '';
  };
in
{
  services.udev.extraRules = ''
    ACTION=="add", ENV{ID_FS_TYPE}=="zfs_member", ENV{ID_FS_LABEL}=="backup-?", TAG+="systemd", ENV{SYSTEMD_WANTS}+="offsite-backup@$env{ID_FS_LABEL}.service"
  '';

  systemd.services."offsite-backup@" = {
    description = "Replicate the storage pool to offsite disk %i";
    # Don't start before the source pool is imported and the key is loaded.
    after = [ "zfs-import-storage.service" ];
    requires = [ "zfs-import-storage.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${offsite-backup}/bin/offsite-backup %i";
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };
}
