# Disk layout for soto-server.
#
#   NVMe (Micron 7300 1.92 TB, disk "primary")
#     ESP 1 GB            /boot
#     bcachefs 240 GB     encrypted root (member 1 of a future 2-member mirror;
#                         a second SSD is added later with `bcachefs device add`)
#     zfs (rest)          L2ARC read cache for the `storage` pool (disposable)
#
#   3x 14 TB HDD behind the PERC H730 (bays 0-2, passthrough disks)
#     ZFS 3-way mirror `storage`, natively encrypted with the same passphrase as
#     the root filesystem. Bays 3 and 4 are deliberately NOT here: bay 3 is the
#     cold spare, bay 4 holds whichever offsite backup disk is at home.
#
# The passphrase file path below is where scripts/nixos-anywhere.sh places the
# `fde_password` secret during installation, and where sops-nix places it on the
# running system, so the same path works for formatting and for key loading at boot.
{ lib, ... }:
let
  # Literal rather than `config.sops.secrets.<name>.path`: the initrd SSH module
  # gates on disko's bcachefs passwordFile, and sops' option set includes that
  # module's definitions, so referencing the option here would recurse. This is
  # sops-nix's default path for the secret declared below.
  passwordFile = "/run/secrets/hosts/nixos/soto-server/fde_password";

  esp = import ../../../modules/defaults/disko/esp.nix;
  root = import ../../../modules/defaults/disko/root.nix {
    inherit lib passwordFile;
    fs = "bcachefs";
    encrypted = true;
    # Raise to 2 once the second SSD is a member of the filesystem.
    replicas = 1;
  };
  zfsDisk = import ../../../modules/defaults/disko/zfs_disk.nix;
  dataset =
    name: mountpoint:
    (import ../../../modules/defaults/disko/zfs_dataset.nix {
      inherit lib mountpoint;
      name = "storage/${name}";
    })
    // {
      inherit mountpoint;
    };
in
{
  sops.secrets."hosts/nixos/soto-server/fde_password" = {
    sopsFile = ./secrets.yaml;
  };

  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Micron_7300_MTFDHBE1T9TDF_20492BD7DC2D";
        content = {
          type = "gpt";
          partitions = {
            ESP = esp // {
              priority = 1;
            };
            root = root.partition.root // {
              priority = 2;
              size = "240G";
            };
            # The rest of the NVMe joins the `storage` pool as its L2ARC read
            # cache (`cache = [ "primary" ]` in the topology below). Nothing is
            # lost if it dies; the pool just gets slower.
            zfs = {
              priority = 3;
              size = "100%";
              content = {
                type = "zfs";
                pool = "storage";
              };
            };
          };
        };
      };

      # Bay 0
      hdd0 = zfsDisk { device = "/dev/disk/by-id/ata-WDC_WD140EMFZ-11A0WA0_Z2HGS6JT"; };
      # Bay 1
      hdd1 = zfsDisk { device = "/dev/disk/by-id/ata-WDC_WD140EDFZ-11A0VA0_9MGG29RK"; };
      # Bay 2
      hdd2 = zfsDisk { device = "/dev/disk/by-id/ata-WDC_WD140EDFZ-11A0VA0_9MGG9K1K"; };
    };

    bcachefs_filesystems = root.bcachefs_filesystems;

    zpool.storage = {
      type = "zpool";
      mode.topology = {
        type = "topology";
        vdev = [
          {
            mode = "mirror";
            members = [
              "hdd0"
              "hdd1"
              "hdd2"
            ];
          }
        ];
        # L2ARC on the NVMe. Losing it loses nothing.
        cache = [ "primary" ];
      };
      options = {
        ashift = "12";
        autotrim = "on";
      };
      rootFsOptions = {
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        dnodesize = "auto";
        normalization = "formD";
        canmount = "off";
        mountpoint = "none";
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
        keylocation = "file://${passwordFile}";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        photos = dataset "photos" "/storage/photos";
        media = dataset "media" "/storage/media";
        timemachine = dataset "timemachine" "/storage/timemachine";
        backups = dataset "backups" "/storage/backups";
        # Hourly copy of the SSD's non-reproducible state; see ssd-state-backup.nix
        "backups/soto-ssd" = dataset "backups/soto-ssd" "/storage/backups/soto-ssd";
      };
    };
  };
}
