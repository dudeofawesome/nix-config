{ os, pkgs, ... }:
{
  imports = [
    ./${os}.nix
  ];
}
