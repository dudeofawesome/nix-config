{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.finicky;
in
{
  options = {
    programs.finicky = {
      enable = mkEnableOption "Configure Finicky";

      settings = mkOption {
        type = types.lines;
        example = ''
          // Use https://finicky-kickstart.now.sh to generate basic configuration
          // Learn more about configuration options:
          // https://github.com/johnste/finicky/wiki/Configuration

          module.exports = {
            defaultBrowser: 'Firefox',
          };
        '';
        description = ''
          JavaScript configuration for Finicky
        '';
      };
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home = {
      # packages = with pkgs; [
      #   nixcasks.finicky
      # ];
    };

    programs.firefox.policies.DontCheckDefaultBrowser = true;
    programs.chromium.commandLineArgs = [ "no-default-browser-check" ];

    xdg.configFile.finicky = {
      target = "finicky.js";
      text = cfg.settings;
      onChange = ''
        run /usr/bin/defaults write \
          net.kassett.finicky config_location_bookmark \
            -data "$(${lib.getExe pkgs.mkalias} -f hex "${config.home.homeDirectory}/${config.xdg.configFile.finicky.target}")"
      '';
    };
  };
}
