{
  owner,
  pkgs,
  ...
}:
{
  imports = [
    ./gnome.nix
    ../jovian.nix
    ../plymouth.nix
  ];

  nixpkgs.overlays = [ (import ../../../overlays/discord-without-preload.nix) ];

  # Jovian's Game Mode starts Steam Big Picture in Gamescope directly at boot.
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = owner;
    };
    decky-loader = {
      enable = true;
      extraPackages = with pkgs; [
        procps
        systemd
      ];
      user = owner;

      modules = {
        css-loader.enable = true;
        launch-options.enable = true;
        pause-games.enable = true;
        protondb-decky.enable = true;
        steamgriddb.enable = true;
        tabmaster.enable = true;
        themedeck.enable = true;
      };
    };
  };

  services = {
    geoclue2.appConfig.darkman = {
      isAllowed = true;
      isSystem = true;
    };
  };

  # Steam's Gamescope session does not run GNOME Shell, so use Darkman as the
  # system appearance source there. It switches at sunrise/sunset using
  # GeoClue and implements the Settings portal used by Electron applications.
  xdg.portal = {
    extraPortals = [ pkgs.darkman ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
      };
      gamescope = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
      };
    };
  };
}
