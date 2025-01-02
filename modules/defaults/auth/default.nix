{
  os,
  users,
  lib,
  ...
}:
{
  imports = [
    ./default.${os}.nix
  ];

  config = lib.concatMapAttrs (
    key: val:
    (
      { }
      // (if (val.config ? "default") then val.config.default else { })
      // (if (val.config ? "${os}") then val.config.${os} else { })
    )
  ) users;
}
