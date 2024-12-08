{ pkgs, ... }:
let
  # Linux6.2 and later add DRM to exported symbols, which are required on aarch64
  removeLinuxDRM =
    pkgs.stdenv.targetPlatform.isAarch64 && ((builtins.compareVersions pkgs.linux.version "6.2") != -1);
in
{
  environment.systemPackages = with pkgs; [
    zfs
  ];

  boot = {
    zfs = {
      removeLinuxDRM = removeLinuxDRM;
      allowHibernation = false;
    };

    kernelPackages =
      (pkgs.zfs.override {
        inherit removeLinuxDRM;
      }).latestCompatibleLinuxPackages;

    supportedFilesystems = [ "zfs" ];
  };

  # Enable auto-trim for SSDs.
  services.zfs.trim.enable = true;
  # Enable auto-scrub.
  services.zfs.autoScrub.enable = true;

  # TODO: services.sanoid
}
