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

  config = lib.mkMerge (
    lib.mapAttrsToList (
      _key: val:
      if val ? "os" then
        lib.mkMerge [
          (lib.optionalAttrs (val.os ? "default") (val.os.default { inherit config lib; }))
          (lib.optionalAttrs (val.os ? "${os}") (val.os.${os} { inherit config lib; }))
        ]
      else
        { }
    ) users
  );
}
