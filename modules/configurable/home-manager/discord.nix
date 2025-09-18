{
  config,
  pkgs-unstable,
  lib,
  ...
}:
let
  cfg = config.programs.discord;
in
{
  options = {
    programs.discord = {
      enable = lib.mkEnableOption "Discord desktop app";

      package =
        lib.mkPackageOption pkgs-unstable "All-in-one cross-platform voice and text chat for gamers"
          {
            default = [ "discord" ];
          };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
