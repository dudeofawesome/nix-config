{ pkgs, lib, ... }:
{
  home = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    file.hammerspoon = {
      target = ".config/hammerspoon/";
      source = "${pkgs.dotfiles.dudeofawesome}/settings/hammerspoon/";
    };

    activation.hammerspoon = ''
      PATH="/usr/bin:$PATH" $DRY_RUN_CMD defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
    '';
  };
}
