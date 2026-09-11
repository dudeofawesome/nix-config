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
      # Set this to the verified system drive before running Disko.
      device = "/dev/disk/by-id/nvme-Micron_7300_MTFDHBE1T9TDF_20492BD7CB17";
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
