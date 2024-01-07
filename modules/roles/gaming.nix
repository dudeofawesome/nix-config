{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
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
}
