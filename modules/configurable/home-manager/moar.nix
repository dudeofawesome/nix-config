{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.moar;
in
{
  options = {
    programs.moar = {
      enable = mkEnableOption "Configure moar pager";

      defaultPager = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to configure {command}`moar` as the default
          pager using the {env}`PAGER` environment variable.
        '';
      };
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = mkIf cfg.defaultPager {
      PAGER = "${pkgs.moar}/bin/moar";
    };
  };
}
