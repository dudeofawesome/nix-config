{
  lib,
  pkgs,
  config,
  options,
  os,
  ...
}:
let
  has_decky = options ? jovian.decky-loader.enable;
in
{
  options = {
    jovian.decky-loader.modules.themedeck = {
      enable = lib.mkEnableOption "themedeck";
      package = lib.mkPackageOption pkgs "themedeck" {
        default = [ "themedeck" ];
      };
    };
  };

  config = (
    let
      cfg = config.jovian.decky-loader;
      themedeck = cfg.modules.themedeck;
      has_themedeck_pot_provider = themedeck.enable && themedeck.package ? potProvider;
    in
    lib.mkIf (has_decky && cfg.enable) {
      systemd.services.decky-loader = lib.mkIf (cfg.plugins != [ ] && has_themedeck_pot_provider) {
        after = lib.optional has_themedeck_pot_provider "themedeck-pot-provider.service";
        requires = lib.optional has_themedeck_pot_provider "themedeck-pot-provider.service";
      };

      systemd.services.themedeck-pot-provider = lib.mkIf has_themedeck_pot_provider {
        description = "ThemeDeck yt-dlp proof-of-origin token provider";

        serviceConfig = {
          DynamicUser = true;
          ExecStart = themedeck.package.potProvider;
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
          Restart = "on-failure";
        };
      };
    }
  );
}
