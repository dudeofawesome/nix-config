{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.asimov =
    let
      inherit (lib.options)
        mkEnableOption
        mkOption
        mkPackageOption
        ;
    in
    {
      enable = mkEnableOption "the Asimov Time Machine exclusion tool";

      package = mkPackageOption pkgs "asimov" { };

      interval = mkOption {
        type = lib.types.int;
        default = 86400;
        description = ''
          How often to run Asimov, in seconds. Defaults to once every 24 hours.
        '';
      };
    };

  config =
    let
      cfg = config.services.asimov;
    in
    lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isDarwin) {
      home.packages = [ cfg.package ];

      launchd.agents.asimov = {
        enable = true;
        config = {
          Label = "com.stevegrunwell.asimov";
          ProgramArguments = [ (lib.getExe cfg.package) ];
          RunAtLoad = true;
          StartInterval = cfg.interval;
        };
      };
    };
}
