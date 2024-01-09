{ pkgs, lib, osConfig, ... }: {
  dconf.settings = lib.mkIf pkgs.stdenv.targetPlatform.isLinux {
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
}
