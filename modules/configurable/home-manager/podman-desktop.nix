{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  options = {
    programs.podman-desktop = {
      enable = lib.mkEnableOption "podman-desktop";

      extraConfig = lib.mkOption {
        description = "Extra config options for podman-desktop's settings.json";
        type = lib.types.attrs;
        default = { };
        example = {
          "telemetry.enabled" = false;
          "preferences.login.start" = false;
        };
      };
    };
  };

  config =
    let
      cfg = config.programs.podman-desktop;
      osCfg = osConfig.virtualisation.podman;
    in
    lib.mkIf cfg.enable {
      home.file-json.podman-desktop-settings = lib.mkIf (cfg.extraConfig != { }) {
        inherit (cfg) enable extraConfig;
        target =
          if (pkgs.stdenv.targetPlatform.isDarwin) then
            ".local/share/containers/podman-desktop/configuration/settings.json"
          else
            abort "unsupported OS ${pkgs.stdenv.targetPlatform.config}";
      };

      # TODO: should this be in the default value?
      programs.podman-desktop.extraConfig = {
        "podman.binary.path" = (lib.getExe osCfg.package);
      };
    };
}
