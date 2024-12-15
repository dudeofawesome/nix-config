{
  inputs,
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.quartz.windowManager.aerospace;
in
{
  options = {
    quartz.windowManager.aerospace = {
      enable = mkEnableOption "AeroSpace tiling window manager";

      package = lib.mkPackageOption pkgs-unstable "aerospace" { };

      settings = mkOption {
        description = "Configuration for AeroSpace";
        type = types.attrs;
        default = {
          # You can use it to add commands that run after login to macOS user session.
          # 'start-at-login' needs to be 'true' for 'after-login-command' to work
          # Available commands: https://nikitabobko.github.io/AeroSpace/commands
          after-login-command = [ ];

          # You can use it to add commands that run after AeroSpace startup.
          # 'after-startup-command' is run after 'after-login-command'
          # Available commands : https://nikitabobko.github.io/AeroSpace/commands
          after-startup-command = [ ];

          # Start AeroSpace at login
          start-at-login = true;

          # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;

          # Possible values: tiles|accordion
          default-root-container-layout = "tiles";

          # Possible values: horizontal|vertical|auto
          # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
          #               tall monitor (anything higher than wide) gets vertical orientation
          default-root-container-orientation = "auto";
        };
      };

      extraConfig = mkOption {
        description = "Extra lines appended to the AeroSpace config file";
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.packages = [ cfg.package ];

    xdg.configFile.aerospace = {
      target = "aerospace/aerospace.toml";
      text =
        (lib.pipe
          [
            ''
              # Generated by Home Manager.
              # See https://nikitabobko.github.io/AeroSpace/guide#configuring-aerospace
            ''
            (inputs.nix-std.lib.serde.toTOML cfg.settings)
            cfg.extraConfig
          ]
          [
            (builtins.filter (el: el != null))
            (lib.concatStringsSep "\n")
          ]
        )
        + "\n";
    };

    # TODO: the AeroSpace GUI bin has a `--config-path` flag
    home.activation.aerospace = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] "${lib.getExe cfg.package} reload-config";

    # TODO: use `mkDefault` and `warnings` instead of `mkForce`
    targets.darwin.defaults = {
      "com.apple.dock" = {
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
        expose-group-apps = mkForce true;
      };

      "com.apple.spaces" = {
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
        spans-displays = mkForce true;
      };
    };
  };
}
