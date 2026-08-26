{ lib, os, ... }:
{
  imports = lib.pipe (builtins.readDir ./.) [
    (lib.filterAttrs (_: type: type == "regular"))
    (lib.filterAttrs (name: type: name != "default.nix"))
    (lib.filterAttrs (
      name: type:
      (
        (lib.hasSuffix ".${os}.nix" name)
        || (!(lib.hasSuffix ".linux.nix" name) && !(lib.hasSuffix ".darwin.nix" name))
      )
    ))
    (lib.mapAttrsToList (name: type: (./. + "/${name}")))
  ];
}
