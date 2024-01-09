{ pkgs, lib, os, ... }: with lib; {
  imports = [
    ../defaults/headful/gnome.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      _1password-gui
      cider
      spotify
      # sublime4
    ];
  };
}
