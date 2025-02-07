{
  os,
  users,
  lib,
  config,
  ...
}:
{
  imports = [
    ./default.${os}.nix
  ];

  config = lib.concatMapAttrs (
    key: val:
    if (val ? "os") then
      (
        { }
        // (if (val.os ? "default") then (val.os.default { inherit config lib; }) else { })
        // (if (val.os ? "${os}") then (val.os.${os} { inherit config lib; }) else { })
      )
    else
      ({ })
  ) users;
}
