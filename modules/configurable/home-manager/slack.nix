{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.slack;
in
{
  options = {
    programs.slack = {
      enable = lib.mkEnableOption "Slack desktop app";

      package = lib.mkPackageOption pkgs "Desktop client for Slack" {
        default = [ "slack" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
