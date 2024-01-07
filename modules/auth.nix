{ os, pkgs, ... }:
{
  imports = [
    ./auth.${os}.nix
  ];
}
