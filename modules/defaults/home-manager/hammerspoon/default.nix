{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."org.hammerspoon.Hammerspoon" = {
        MJConfigFile = ./init.lua;
      };
    };
  };
}
