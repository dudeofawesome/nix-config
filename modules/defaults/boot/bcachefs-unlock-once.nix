# Unlock an encrypted bcachefs root once, not once per subvolume mount.
#
# NixOS generates an `unlock-bcachefs-<mountpoint>` initrd service for every
# bcachefs entry in `fileSystems`. When /home, /nix, /tmp, … are subvolumes of
# the root filesystem, they are mounted from the filesystem the root mount
# already opened and need no key of their own; their generated unlock services
# only prompt again (or race the root mount). This skips them for every
# bcachefs entry that lives on the same device as `/`.
#
# Imported by modules/defaults/fs/bcachefs.nix, so every bcachefs host gets it.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  firstDevice = fs: lib.head (lib.splitString ":" fs.device);
  root = config.fileSystems."/" or null;
  rootIsBcachefs = root != null && root.fsType == "bcachefs";
  subvolumesOfRoot = lib.filter (
    fs:
    fs.fsType == "bcachefs"
    && fs.mountPoint != "/"
    && utils.fsNeededForBoot fs
    && firstDevice fs == firstDevice root
  ) (lib.attrValues config.fileSystems);
in
{
  config = lib.mkIf (config.boot.initrd.systemd.enable && rootIsBcachefs) {
    boot.initrd.systemd.services =
      lib.genAttrs (map (fs: "unlock-bcachefs-${utils.escapeSystemdPath fs.mountPoint}") subvolumesOfRoot)
        (_: {
          # A failing ExecCondition skips the unit without failing its mount.
          serviceConfig.ExecCondition = lib.mkForce (lib.getExe' pkgs.coreutils "false");
        });
  };
}
