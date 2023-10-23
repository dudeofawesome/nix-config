{ pkgs, lib, osConfig, ... }:
{
  imports = [
    ./editors.nix
    ./miscellaneous.nix
    ./shells.nix
  ];
}
