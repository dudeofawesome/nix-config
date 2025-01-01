{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options)
    mkEnableOption
    mkOption
    mkPackageOption
    ;
  inherit (lib.types)
    enum
    nullOr
    str
    int
    submodule
    ;
  launchdTypes = import "${inputs.darwin}/modules/launchd/types.nix" { inherit config lib; };

  cfg = config.services.scrutiny;
  # Define the settings format used for this program
  settingsFormat = pkgs.formats.yaml { };
in
{
  options = {
    services.scrutiny = {
      collector = {
        enable = mkEnableOption "the Scrutiny metrics collector" // {
          default = cfg.enable;
          defaultText = lib.literalExpression "config.services.scrutiny.enable";
        };

        package = mkPackageOption pkgs "scrutiny-collector" { };

        schedule = mkOption {
          type = launchdTypes.StartCalendarInterval;
          default = {
            Hour = 3;
            Minute = 15;
          };
          description = ''
            How often to run the collector in launchd calendar format.
          '';
        };

        settings = mkOption {
          description = ''
            Collector settings to be rendered into the collector configuration file.

            See https://github.com/AnalogJ/scrutiny/blob/master/example.collector.yaml.
          '';
          default = { };
          type = submodule {
            freeformType = settingsFormat.type;

            options = {
              version = mkOption {
                type = int;
                default = 1;
                description = "Specifies the version of the settings schema";
              };

              host.id = mkOption {
                type = nullOr str;
                default = null;
                description = "Host ID for identifying/labelling groups of disks";
              };

              api.endpoint = mkOption {
                type = nullOr str;
                default = null;
                description = "Scrutiny app API endpoint for sending metrics to";
              };

              log.level = mkOption {
                type = enum [
                  "INFO"
                  "DEBUG"
                ];
                default = "INFO";
                description = "Log level for Scrutiny collector.";
              };
            };
          };
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.collector.enable {
      # services.smartd = {
      #   enable = true;
      #   extraOptions = [
      #     "-A /var/log/smartd/"
      #     "--interval=600"
      #   ];
      # };

      launchd.daemons.scrutiny-collector = {
        serviceConfig = {
          ProgramArguments = [
            (getExe cfg.collector.package)
            "run"
            "--config"
            (builtins.toString (settingsFormat.generate "scrutiny-collector.yaml" cfg.collector.settings))
          ];

          ProcessType = "Background";

          RunAtLoad = true;
          StartCalendarInterval = cfg.collector.schedule;
        };
      };
    })
  ];

  # meta.maintainers = [ maintainers.jnsgruk ];
}
