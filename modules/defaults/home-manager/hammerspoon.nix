{ pkgs, lib, config, ... }:
{
  targets.darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    defaults."org.hammerspoon.Hammerspoon" = {
      MJConfigFile = "/Users/${config.home.username}/.config/hammerspoon/init.lua";
    };
  };

  home = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    file.hammerspoon = {
      target = ".config/hammerspoon/";
      source = "${pkgs.dotfiles.dudeofawesome}/settings/hammerspoon/";
    };
  };
}
