# Disk layout for soto-server.
#
#   NVMe (Micron 7300 1.92 TB, disk "primary")
#     ESP 1 GB            /boot
#     bcachefs 240 GB     encrypted root. Member 1 of a 2-member mirror: a
#                         240 GB SATA SSD (223 GiB) joins later with
#                         `bcachefs device add`. With replicas=2 the smaller
#                         device sets the usable size, so growing this
#                         partition only pays off once that SSD is replaced.
#     zfs (rest)          L2ARC read cache for the `storage` pool (disposable)
#
#   3x 14 TB HDD behind the PERC H730 (bays 0-2, passthrough disks)
#     ZFS 3-way mirror `storage`, natively encrypted with the same passphrase as
#     the root filesystem. Bays 3 and 4 are deliberately NOT here: bay 3 is the
#     cold spare, bay 4 holds whichever offsite backup disk is at home.
#     The pool's root dataset is mounted at /storage and owned by josh, so
#     folders can be made there directly; only things that need their own
#     properties are separate datasets. Ownership is set once, at
#     installation (zfs_owner_hook.nix), because it lives in the dataset.
#
# The passphrase file path below is where scripts/nixos-anywhere.sh places the
# `fde_password` secret during installation, and where sops-nix places it on the
# running system, so the same path works for formatting and for key loading at boot.
{ config, lib, ... }:
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
  ownerHook = import ../../../modules/defaults/disko/zfs_owner_hook.nix;
  rootMountPoint = config.disko.rootMountPoint;
  # josh:users, numeric because the hooks run in the installer. The uid is
  # pinned in default.nix.
  josh = "1000:100";
  dataset =
    name:
    {
      owner ? null,
      compression ? true,
    }:
    (import ../../../modules/defaults/disko/zfs_dataset.nix {
      inherit
        lib
        owner
        compression
        rootMountPoint
        ;
      name = "storage/${name}";
      mountpoint = "/storage/${name}";
    })
    // {
      mountpoint = "/storage/${name}";
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

      hdd0 = zfsDisk { device = "/dev/disk/by-id/ata-WDC_WD140EMFZ-11A0WA0_Z2HGS6JT"; };
      hdd1 = zfsDisk { device = "/dev/disk/by-id/ata-WDC_WD140EDFZ-11A0VA0_9MGG29RK"; };
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
      mountpoint = "/storage";
      rootFsOptions = {
        compression = "zstd";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
        dnodesize = "auto";
        normalization = "formD";
        encryption = "aes-256-gcm";
        keyformat = "passphrase";
        keylocation = "file://${passwordFile}";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        # The root dataset itself (disko's name for it), mounted at /storage.
        "__root".postMountHook = ownerHook {
          owner = josh;
          mountpoint = "/storage";
          inherit rootMountPoint;
        };
        # Photos and video are already compressed; don't spend CPU on them.
        photos = dataset "photos" {
          owner = josh;
          compression = false;
        };
        media = dataset "media" {
          owner = josh;
          compression = false;
        };
        # Owned by the Time Machine user, set by the time-machine module.
        timemachine = dataset "timemachine" { };
        # Root-owned restic repository (ssd-state-backup.nix).
        backups = dataset "backups" { };
        "backups/soto-ssd" = dataset "backups/soto-ssd" { };
      };
    };
  };
}
