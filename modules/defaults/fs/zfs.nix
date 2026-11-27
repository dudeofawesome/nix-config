# ZFS support for data pools (not the root filesystem).
#
# Kernel: nixpkgs removed `zfs.latestCompatibleLinuxPackages`, the attribute
# this module used to pick the newest kernel ZFS supported. Upstream's
# replacement is simply the default (LTS) kernel, which ZFS always supports, so
# ZFS hosts override the base preset's `linuxPackages_latest` with it. A host
# that needs a newer kernel can set `boot.kernelPackages` with a lower
# mkOverride priority. A kernel ZFS doesn't support fails at evaluation, not at
# boot: nixpkgs marks the ZFS kernel module `broken` outside the range ZFS's
# META file declares (pkgs/os-specific/linux/zfs/generic.nix), and the NixOS
# zfs module asserts the module and userspace versions match.
#
# Snapshot schedules: modules/configurable/os/zfs-snapshots.linux.nix.
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
    kernelPackages = lib.mkOverride 900 pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs = {
      inherit removeLinuxDRM;
      unsafeAllowHibernation = false;
      # No ZFS root here, and nixpkgs recommends false (the 26.11 default).
      forceImportRoot = false;
    };
  };

  environment.systemPackages = [ config.boot.zfs.package ];

  # Every dataset is mounted by its own systemd mount unit (fileSystems, as
  # disko generates them). zfs-mount.service (`zfs mount -a`) races those
  # units at boot and, once a pool's root dataset is mountable, wins: the unit
  # then fails with "dataset is busy", local-fs.target fails, and the boot
  # stops in emergency mode until someone presses Enter on the console. Masked.
  systemd.services.zfs-mount.enable = false;

  services.zfs = {
    # Weekly scrub of every imported pool.
    autoScrub.enable = true;
    # TRIM pools backed by SSDs (no-op for spinning disks).
    trim.enable = true;
  };
}
