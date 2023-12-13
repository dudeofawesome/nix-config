{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
  ];

  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Enable auto-trim for SSDs.
  services.zfs.trim.enable = true;
  # Enable auto-scrub.
  services.zfs.autoScrub.enable = true;

  # TODO: services.sanoid
}
