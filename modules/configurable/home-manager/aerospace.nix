{ inputs, pkgs, lib, config, ... }:
with lib; let
  cfg = config.programs.aerospace;
in
{
  options = {
    programs.aerospace = {
      enable = mkEnableOption "AeroSpace tiling window manager";

      extraConfig = mkOption {
        description = "configuration for AeroSpace";
        type = types.attrs;
        default = { };
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    xdg.configFile.aerospace = {
      target = "aerospace/aerospace.toml";
      text = inputs.nix-std.lib.serde.toTOML cfg.extraConfig;
    };

    home.activation.aerospace = lib.hm.dag.entryAfter [ "writeBoundary" ]
      "/opt/homebrew/bin/aerospace reload-config";

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
