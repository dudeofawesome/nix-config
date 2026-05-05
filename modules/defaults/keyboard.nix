{ doa-lib, os, ... }:
{
  imports = [
    (doa-lib.try-import ./keyboard.${os}.nix)
  ];
}
