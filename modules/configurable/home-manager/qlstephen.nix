{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.qlstephen;
in
{
  options = {
    programs.qlstephen = {
      enable = lib.mkEnableOption "QLStephen Quick Look plugin";

      package = lib.mkPackageOption pkgs "QLStephen Quick Look plugin" {
        default = [ "qlstephen" ];
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.file."Library/QuickLook/QLStephen.qlgenerator" = {
      source = "${cfg.package}/Library/QuickLook/QLStephen.qlgenerator";
      onChange = "/usr/bin/qlmanage -r >/dev/null 2>&1 || true";
    };
  };
}
