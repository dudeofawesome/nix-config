{
  lib,
  encrypted ? false,
  passwordFile ? null,
  compression ? "zstd",
  noatime ? true,
}:
assert lib.assertMsg (
  !encrypted || passwordFile != null
) "An encrypted bcachefs filesystem requires passwordFile.";
let
  mountOptionsAttrs = {
    inherit noatime compression;
  };

  convertMountOptions =
    opts:
    lib.pipe opts [
      (lib.filterAttrs (opt: val: (val != false && val != null)))
      (lib.mapAttrsToList (
        opt: val:
        if
          (builtins.elem (builtins.typeOf val) [
            "string"
            "int"
            "float"
          ])
        then
          "${opt}=${val}"
        else
          opt
      ))
    ];
in
{
  partition = {
    root = {
      name = "root";
      size = "100%";
      content = {
        type = "bcachefs";
        label = "root";
      };
    };
  };

  bcachefs_filesystems.root = {
    type = "bcachefs_filesystem";
    inherit passwordFile;
    extraFormatArgs = lib.flatten [
      (lib.optional (compression != null) "--compression=${compression}")
    ];
    subvolumes =
      let
        mountOptions = convertMountOptions mountOptionsAttrs;
      in
      {
        "@root" = {
          mountpoint = "/";
          inherit mountOptions;
        };
        "@home" = {
          mountpoint = "/home";
          inherit mountOptions;
        };
        "@nix" = {
          mountpoint = "/nix";
          mountOptions = convertMountOptions (
            mountOptionsAttrs
            // {
              noatime = true;
              compression = "lz4";
              background_compression = "zstd:15";
            }
          );
        };
        "@tmp" = {
          mountpoint = "/tmp";
          mountOptions = convertMountOptions (
            mountOptionsAttrs
            // {
              noatime = true;
              compression = false;
              # nocow = true;
            }
          );
        };
      };
  };
}
