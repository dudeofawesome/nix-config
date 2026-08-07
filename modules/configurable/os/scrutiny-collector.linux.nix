{
  config,
  lib,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options)
    mkOption
    ;
  inherit (lib.types)
    nullOr
    path
    ;

  cfg = config.services.scrutiny;
in
{
  options = {
    services.scrutiny = {
      collector = {
        api-endpoint-secret = mkOption {
          type = nullOr path;
          description = ''
            A path to a file containing the Scrutiny server API endpoint
          '';
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.collector.enable {
      systemd.services.scrutiny-collector = {
        environment = {
          COLLECTOR_API_ENDPOINT = lib.mkForce null;
        };
        serviceConfig = {
          ExecStart = lib.mkForce (
            lib.pipe
              [
                (getExe cfg.collector.package)
                "run"
                "--config /run/scrutiny-collector/config.yaml"
                (lib.optional (
                  cfg.collector.api-endpoint-secret != null
                ) ''--api-endpoint "$(cat "${cfg.collector.api-endpoint-secret}")"'')
              ]
              [
                lib.flatten
                (lib.concatStringsSep " ")
              ]
          );
        };
      };
    })
  ];
}
