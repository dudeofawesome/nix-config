# ZFS support for data pools (not the root filesystem).
# The kernel is left alone: the pinned nixpkgs builds the ZFS module for the
# kernel the base preset selects, and evaluation fails loudly if it ever can't.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  # Linux 6.2 and later add DRM to exported symbols, which are required on aarch64
  removeLinuxDRM =
    pkgs.stdenv.hostPlatform.isAarch64
    && ((builtins.compareVersions config.boot.kernelPackages.kernel.version "6.2") != -1);
in
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      inherit removeLinuxDRM;
      allowHibernation = false;
    };
  };

  environment.systemPackages = [ config.boot.zfs.package ];

  services.zfs = {
    # Weekly scrub of every imported pool.
    autoScrub.enable = true;
    # TRIM pools backed by SSDs (no-op for spinning disks).
    trim.enable = true;
  };
}
