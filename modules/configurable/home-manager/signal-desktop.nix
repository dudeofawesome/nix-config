{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.signal-desktop;
in
{
  options = {
    programs.signal-desktop = {
      enable = lib.mkEnableOption "Signal desktop app";

      package = lib.mkPackageOption pkgs "Private, simple, and secure messenger" {
        default = [ "signal-desktop-bin" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
