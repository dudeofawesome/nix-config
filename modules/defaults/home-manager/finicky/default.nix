{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    home = {
      # packages = with pkgs; [
      #   nixcasks.finicky
      # ];
    };

    programs.firefox.policies.DontCheckDefaultBrowser = true;
    programs.chromium.commandLineArgs = [ "no-default-browser-check" ];

    xdg.configFile.finicky = {
      target = "finicky.js";
      source = lib.mkDefault ./finicky.js;
      onChange = ''
        PATH="/usr/bin:$PATH" $DRY_RUN_CMD defaults write \
          net.kassett.finicky config_location_bookmark \
            -data "$(${pkgs.mkalias}/bin/mkalias "${config.home.homeDirectory}/${config.xdg.configFile.finicky.target}")"
      '';
    };
  };
}
