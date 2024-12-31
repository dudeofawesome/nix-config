{
  owner,
  machine-class,
  config,
  lib,
  ...
}:
let
  inherit (lib) types mkOption mkIf;
  cfg = config.programs.gnome;
in
{
  options = {
    programs.gnome = {
      autoLoginEnable = mkOption {
        type = types.bool;
        default =
          (machine-class == "local-vm")
          || (config.services.xserver.desktopManager.gnome.enable && config.services.qemuGuest.enable);
        example = true;
        description = ''
          Whether or not the specified user should be automatically logged in.
        '';
      };
      autoLoginUser = mkOption {
        type = types.str;
        default = owner;
        example = "dudeofawesome";
        description = ''
          The name of user that should be automatically logged in.
        '';
      };
    };
  };

  config = {
    services.xserver = {
      displayManager.gdm.settings = {
        daemon = mkIf cfg.autoLoginEnable {
          AutomaticLoginEnable = cfg.autoLoginEnable;
          AutomaticLogin = cfg.autoLoginUser;
        };
      };
    };
  };
}
