{ lib, osConfig, ... }:
{
  config = lib.mkIf osConfig.services.desktopManager.gnome.enable {
    dconf.settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = lib.mkDefault "appmenu:minimize,maximize,close";
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "firefox.desktop"
          "org.gnome.Console.desktop"
          "steam.desktop"
          "org.gnome.Settings.desktop"
        ];
      };
      "org/gnome/desktop/interface" = {
        monospace-font-name = (builtins.elemAt osConfig.fonts.packages 0).name;
      };
    };
  };
}
