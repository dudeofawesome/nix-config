{ lib, os, ... }:
{
  imports = lib.pipe (builtins.readDir ./.) [
    (lib.filterAttrs (
      name: type:
      type == "directory" && builtins.pathExists (./. + "/${name}/default.nix")
      || (
        type == "regular"
        && name != "default.nix"
        && (
          (lib.hasSuffix ".${os}.nix" name)
          || (!(lib.hasSuffix ".linux.nix" name) && !(lib.hasSuffix ".darwin.nix" name))
        )
      )
    ))
    (lib.mapAttrsToList (name: type: (./. + "/${name}")))
  ];
}
