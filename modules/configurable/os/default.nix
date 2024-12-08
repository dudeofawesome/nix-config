{ lib, os, ... }:
let
  doa-lib = import ../../../lib;
in
{
  imports = [
    (doa-lib.try-import ./default.${os}.nix)
  ];
}
