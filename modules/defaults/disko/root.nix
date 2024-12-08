{
  fs ? "ext4",
  encrypted ? false,
  passwordFile ? null,
  lib,
}:
with builtins;
if (!encrypted) then
  ({
    partition = {
      root = {
        name = "root";
        size = "100%";
        content = {
          type = "filesystem";
          format = fs;
          mountpoint = "/";
        };
      };
    };
  })
else
  (
    # use LUKS for filesystems that don't have native encryption support
    if
      (
        !(elem fs [
          "zfs"
          "bcachefs"
        ])
      )
    then
      ({
        partition = {
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              passwordFile = passwordFile;
              content = {
                type = "filesystem";
                format = fs;
                mountpoint = "/";
              };
            };
          };
        };
      })
    # use ZFS's native encryption
    else if (fs == "zfs") then
      ({
        partition = {
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "zfs";
              mountpoint = "/";
            };
          };
        };
      })
        abort
    # use bcachefs's native encryption
    else if (fs == "bcachefs") then
      ({
        partition = {
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
            };
          };
        };
      })
        abort
    else
      abort
  )
