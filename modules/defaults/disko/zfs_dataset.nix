{
  lib,
  snapshot ? true,
  mountpoint,
  compression ? true,
  name ? null,
  # "uid:gid" for the dataset's root directory, set once when disko mounts it
  # (see zfs_owner_hook.nix). null leaves it root-owned.
  owner ? null,
  rootMountPoint ? "/mnt",
}:
let
  a = (if (snapshot != true || name == null) then { } else abort);
in
{
  type = "zfs_fs";

  options = {
    inherit mountpoint;
    compression = if (compression == true) then "zstd" else "off";
    "com.sun:auto-snapshot" = if (snapshot) then "true" else "false";
  };

  postCreateHook = lib.mkIf snapshot "zfs snapshot ${name}@blank";
  postMountHook = lib.mkIf (owner != null) (
    import ./zfs_owner_hook.nix {
      inherit owner mountpoint rootMountPoint;
    }
  );
}
