{ ... }:
{
  # Replace this placeholder with the stable by-id path of the target NVMe
  # before running disko.
  disko.devices.disk.primary = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-CT2000P5SSD8_2323413368F7";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          label = "ESP";
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          label = "bcachefs-root";
          size = "100%";
          type = "8300";
        };
      };
    };
  };
}
