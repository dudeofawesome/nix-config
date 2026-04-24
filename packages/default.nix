{ lib }:
build-inputs:
let
  packageDirs = lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./.);
in
lib.mapAttrs' (name: _: lib.nameValuePair name (import ./${name}/package.nix build-inputs)) (
  lib.filterAttrs (name: _: builtins.pathExists ./${name}/package.nix) packageDirs
)
