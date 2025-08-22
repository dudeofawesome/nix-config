{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;
  cfg = config.programs.docker-client;
in
{
  options = {
    programs.docker-client = {
      enable = lib.mkEnableOption "the Docker CLI";

      package = lib.mkPackageOption pkgs "Docker Client" {
        default = [ "docker-client" ];
      };

      dockerDir = lib.mkOption {
        type = lib.types.str;
        default = ".docker";
      };

      settings = lib.mkOption {
        description = ''Settings for Docker Desktop's settings.json'';
        type = lib.types.attrs;
        default = {
          credsStore =
            if isLinux then
              "pass"
            else if isDarwin then
              "osxkeychain"
            else
              abort;
        };
        example = {
          credsStore = "pass";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
        pkgs.docker-credential-helpers
      ];

      file-json.docker-client-settings = lib.mkIf (cfg.settings != { }) {
        inherit (cfg) enable;
        target = "${cfg.dockerDir}/config.json";
        extraConfig = cfg.settings;
      };
    };
  };
}
