{ lib, config, ... }: {
  options = {
    services.hardware.openrgb.zone_sizes = lib.mkOption {
      description = "Extra config options for 1Password's settings.json";
      type = with lib.types; nullOr path;
      default = null;
      example = lib.literalExpression ''
        ./sizes.ors
      '';
    };
  };

  config =
    let
      cfg = config.services.hardware.openrgb;
    in
    lib.mkIf (cfg.enable && cfg.zone_sizes != null) {
      systemd = {
        tmpfiles.settings.openrgb-sizes = {
          "/var/lib/${config.systemd.services.openrgb.serviceConfig.StateDirectory}/sizes.ors".C =
            lib.mkIf (cfg.zone_sizes != null)
              {
                mode = "0644";
                argument = "${cfg.zone_sizes}";
              };
        };

        services.openrgb =
          let
            tmp_service = "systemd-tmpfiles-setup.service";
          in
          lib.mkIf (cfg.zone_sizes != null) {
            requires = [ tmp_service ];
            after = [ tmp_service ];
          };
      };
    };
}
