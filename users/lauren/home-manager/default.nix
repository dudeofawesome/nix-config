{ lib, pkgs-unstable, ... }:
{
  imports = [
    ../../../modules/defaults/home-manager
    ../../../modules/defaults/home-manager/gnome.nix
    ./vscode
  ];

  home.stateVersion = "23.05";

  home.packages = with pkgs-unstable; [
    devenv
  ];
}
