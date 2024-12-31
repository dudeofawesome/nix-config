{ pkgs-stable, pkgs-unstable, ... }:
{
  imports = [
  ];

  environment = {
    systemPackages = with pkgs-stable; [
      antimicrox
      discord
      # gamescope
      pkgs-unstable.game-devices-udev-rules
      heroic
      parsec-bin
      pkgs-unstable.protontricks
      pkgs-unstable.protonup-qt
      pkgs-unstable.steam
      steam-rom-manager
      steam-tui
      steamguard-cli
      sunshine
    ];
  };

  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   xpadneo
  # ];
  hardware = {
    xpadneo.enable = true;
    xone.enable = true;
    uinput.enable = true;
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
    };
  };
}
