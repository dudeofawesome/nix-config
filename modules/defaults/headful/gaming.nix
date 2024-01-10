{ pkgs, config, ... }: {
  imports = [
    ../8bitdo.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      antimicrox
      discord
      # gamescope
      heroic
      parsec-bin
      protontricks
      protonup-qt
      steam
      steam-rom-manager
      steam-tui
      steamguard-cli
      sunshine
    ];
  };

  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   xpadneo
  # ];
  hardware.xpadneo.enable = true;
  hardware.xone.enable = true;

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
    };
  };
}
