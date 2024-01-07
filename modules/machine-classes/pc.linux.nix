{ pkgs, lib, os, ... }: with lib; {
  imports = [
    ../gnome.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cider
      spotify
      # sublime4
    ];
  };
}
