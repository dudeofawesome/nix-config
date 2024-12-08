{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.doa-system-clock;
in
{
  options = {
    programs.doa-system-clock = {
      enable = mkEnableOption "Set system clock";

      show_24_hour = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether or not to use 24-hour time.
        '';
      };

      show_seconds = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether or not to show seconds.
        '';
      };

      show_date = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether or not to show seconds.
        '';
      };

      show_day_of_week = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          Whether or not to show the day of the week.
        '';
      };
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    targets.darwin.defaults = {
      "com.apple.menuextra.clock" = {
        Show24Hour = cfg.show_24_hour;
        ShowDate = if cfg.show_date then 1 else 0;
        ShowDayOfWeek = cfg.show_day_of_week;
        ShowSeconds = cfg.show_seconds;
      };
      global.AppleICUForce24HourTime = if cfg.show_24_hour then 1 else 0;
    };
  };
}
