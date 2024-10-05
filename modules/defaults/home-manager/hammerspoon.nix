{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "/Users/${config.home.username}/.config/hammerspoon/init.lua";
      };
    };

    home = {
      file.hammerspoon = {
        target = ".config/hammerspoon/";
        source = "${pkgs.dotfiles.dudeofawesome}/settings/hammerspoon/";
      };
    };
  };
}
