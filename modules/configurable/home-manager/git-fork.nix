{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.git-fork;
in
{
  options = {
    programs.git-fork = {
      enable = lib.mkEnableOption "Fork desktop app";

      package = lib.mkPackageOption pkgs "Git client" {
        default = [ "git-fork" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
