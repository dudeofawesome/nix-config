{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.zoom-us;
in
{
  options = {
    programs.zoom-us = {
      enable = lib.mkEnableOption "zoom.us desktop app";

      package = lib.mkPackageOption pkgs "zoom.us video conferencing application" {
        default = [ "zoom-us" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
