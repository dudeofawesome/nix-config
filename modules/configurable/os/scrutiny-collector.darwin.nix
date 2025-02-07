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
    path
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
        enable = mkEnableOption "the Scrutiny metrics collector";

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

        api-endpoint-secret = mkOption {
          type = nullOr path;
          description = ''
            A path to a file containing the Scrutiny server API endpoint
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
        script =
          let
            settings = lib.filterAttrsRecursive (key: val: val != null) cfg.collector.settings;
          in
          lib.concatStringsSep " " (
            lib.flatten [
              (getExe cfg.collector.package)
              "run"
              ''--config "${settingsFormat.generate "scrutiny-collector.yaml" settings}"''
              (lib.optional (
                cfg.collector.api-endpoint-secret != null
              ) ''--api-endpoint "$(cat "${cfg.collector.api-endpoint-secret}")"'')
            ]
          );

        serviceConfig = {
          ProcessType = "Background";

          RunAtLoad = true;
          StartCalendarInterval = cfg.collector.schedule;
        };
      };
    })
  ];

  # meta.maintainers = [ maintainers.jnsgruk ];
}
