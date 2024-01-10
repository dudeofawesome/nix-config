{ os, users, pkgs, lib, ... }:
{
  imports = [
    ./${os}.nix
  ];

  config = lib.concatMapAttrs
    (key: val:
      if (val.config ? "${os}") then val.config.${os} else { })
    users;
}
