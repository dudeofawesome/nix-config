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
  };
}
