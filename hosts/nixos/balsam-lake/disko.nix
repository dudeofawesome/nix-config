{ lib, ... }:
let
  root = import ../../../modules/defaults/disko/root.nix {
    inherit lib;
    fs = "bcachefs";
    encrypted = true;
    passwordFile = "/tmp/bcachefs-password";
  };
in
{
  disko.devices = {
    disk.primary = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-BC711_NVMe_SK_hynix_128GB____CD11N4545116Y1E3D";
      content = {
        type = "gpt";
        partitions = {
          ESP = (import ../../../modules/defaults/disko/esp.nix) // {
            # Leave room for multiple signed boot generations.
            size = "2000M";
          };
        }
        // root.partition;
      };
    };

    bcachefs_filesystems = root.bcachefs_filesystems;
  };
}
