{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.docker-client;
in
{
  options = {
    programs.docker-client = {
      enable = lib.mkEnableOption "the Docker CLI";

      package = lib.mkPackageOption pkgs "Docker Client" {
        default = [ "docker-client" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
