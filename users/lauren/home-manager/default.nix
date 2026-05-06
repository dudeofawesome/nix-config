{ lib, pkgs-unstable, ... }:
{
  imports = [
    ../../../modules/defaults/home-manager
    ./vscode
  ];

  home.stateVersion = "23.05";

  home.packages = with pkgs-unstable; [
    devenv
  ];
}
