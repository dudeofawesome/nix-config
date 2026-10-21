# Offsite backup disks: single-disk ZFS pools named `backup-a` / `backup-b`.
#
# Slide one into a free bay and udev starts `offsite-backup@backup-a.service`,
# which imports the pool, replicates every `storage` dataset as raw (still
# encrypted) incremental sends, scrubs the disk, exports the pool and logs a
# completion line. When it is done the bay's blue locate LED comes on: pull
# the disk (the backplane clears the LED). If it failed, the amber fault LED
# comes on instead; `journalctl -u 'offsite-backup@*'` has the details.
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
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnused
    ];
    text = ''
      pool="$1"
      case "$pool" in
        backup-[a-z]) ;;
        *) echo "refusing to use '$pool' as an offsite pool" >&2; exit 1 ;;
      esac

      # Bay LEDs. The kernel exposes the backplane's slots under
      # /sys/class/enclosure, and on this PERC in passthrough mode a disk's
      # SCSI target id is its slot number.
      slot=""
      led() {
        [ -n "$slot" ] || return 0
        for e in /sys/class/enclosure/*; do
          if [ -e "$e/$slot/$1" ]; then echo "$2" > "$e/$slot/$1" || true; fi
        done
      }
      failed() {
        echo "offsite backup to $pool FAILED; leaving the pool exported" >&2
        zpool export "$pool" 2>/dev/null || true
        led fault 1
      }
      trap failed ERR

      echo "importing $pool"
      zpool import -N "$pool"
      disk=$(zpool list -vHP "$pool" | awk 'NR == 2 { print $1 }')
      blk=$(basename "$(readlink -f "$disk")" | sed 's/[0-9]*$//')
      slot=$(basename "$(readlink -f "/sys/block/$blk/device")" | cut -d: -f3)
      echo "$pool is $disk in bay $slot"
      led locate 0
      led fault 0

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

      zpool export "$pool"
      echo "offsite backup to $pool complete; the disk can be removed"
      led locate 1
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
