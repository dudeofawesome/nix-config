{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.quicklook-json;
in
{
  options = {
    programs.quicklook-json = {
      enable = lib.mkEnableOption "QuickLook JSON Quick Look plugin";

      package = lib.mkPackageOption pkgs "QuickLook JSON Quick Look plugin" {
        default = [ "quicklook-json" ];
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.file."Library/QuickLook/QuickLookJSON.qlgenerator" = {
      source = "${cfg.package}/Library/QuickLook/QuickLookJSON.qlgenerator";
      onChange = "/usr/bin/qlmanage -r >/dev/null 2>&1 || true";
    };
  };
}
