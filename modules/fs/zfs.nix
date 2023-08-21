{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
  ];

  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # TODO: services.zfs.trim.enable = true;
  # TODO: services.sanoid
}
