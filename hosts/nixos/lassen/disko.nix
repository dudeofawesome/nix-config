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
      device = "/dev/disk/by-id/nvme-WDC_CH_SN530_SDBPTPZ-1T00-1024_21360P803868";
      content = {
        type = "gpt";
        partitions = {
          ESP = (import ../../../modules/defaults/disko/esp.nix) // {
            # running unstable means more kernel changes
            size = "2000M";
          };
        }
        // root.partition;
      };
    };

    bcachefs_filesystems = root.bcachefs_filesystems;
  };
}
