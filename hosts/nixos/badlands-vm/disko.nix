{ lib }:
let
  esp = import ../../../modules/defaults/disko/esp.nix;
  root = import ../../../modules/defaults/disko/root.nix {
    inherit lib;
    fs = "bcachefs";
  };
in
{
  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = esp // root;
        };
      };
      storage_1 = import ../../../modules/defaults/disko/zfs_disk.nix { device = "/dev/vdb"; };
      storage_2 = import ../../../modules/defaults/disko/zfs_disk.nix { device = "/dev/vdc"; };
      storage_3 = import ../../../modules/defaults/disko/zfs_disk.nix { device = "/dev/vdd"; };
    };
    zpool = {
      storage = {
        type = "zpool";
        mode = "raidz1";
        # mountpoint = "/mnt/storage";
        rootFsOptions = {
          canmount = "off";
          atime = "off";
          compression = "zstd";
          reservation = "10M";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          encrypted = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///tmp/secret.key";
            };
            # use this to read the key during boot
            # postCreateHook = ''
            #   zfs set keylocation="prompt" "zroot/$name";
            # '';
          };
          "encrypted/time-machine" = import ../../../modules/defaults/disko/zfs_dataset.nix {
            name = "storage/time-machine";
            mountpoint = "/mnt/time-machine";
            snapshot = true;
          };
          "encrypted/linux-isos" = import ../../../modules/defaults/disko/zfs_dataset.nix {
            name = "storage/linux-isos";
            mountpoint = "/mnt/linux-isos";
            snapshot = true;
          };
        };
      };
    };
  };
}
