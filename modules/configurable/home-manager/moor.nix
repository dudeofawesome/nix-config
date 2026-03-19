{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.moor;
in
{
  options = {
    programs.moor = {
      enable = mkEnableOption "Configure moor pager";

      defaultPager = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to configure {command}`moor` as the default
          pager using the {env}`PAGER` environment variable.
        '';
      };
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = mkIf cfg.defaultPager {
      PAGER = lib.getExe pkgs.moor;
    };
  };
}
