{ lib, snapshot ? true, mountpoint, compression, name ? null }:
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
}
