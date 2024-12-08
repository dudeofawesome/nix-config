{ os, ... }:
let
  doa-lib = import ../../lib;
in
{
  imports = [
    (doa-lib.try-import ./keyboard.${os}.nix)
  ];
}
