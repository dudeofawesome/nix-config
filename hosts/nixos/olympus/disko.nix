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
      device = "/dev/disk/by-id/nvme-CT2000P5PSSD8_2323413368F7";
      content = {
        type = "gpt";
        partitions = {
          ESP = import ../../../modules/defaults/disko/esp.nix;
        }
        // root.partition;
      };
    };

    bcachefs_filesystems = root.bcachefs_filesystems;
  };
}
