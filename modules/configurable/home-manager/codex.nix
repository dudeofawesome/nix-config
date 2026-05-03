{ lib, config, ... }:
{
  options =
    let
      inherit (lib) mkOption;
    in
    {
      programs.codex = {
        mutableSettings = mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };

  config =
    let
      cfg = config.programs.codex;

      inherit (config.home) preferXdgDirectories;

      xdgConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
      configDir = if preferXdgDirectories then "${xdgConfigHome}/codex" else ".codex";
      configFileName = "config.toml";

      settings_path = "${configDir}/${configFileName}";
    in
    lib.mkIf (cfg.mutableSettings) {
      home.file."/${settings_path}".enable = lib.mkForce false;
      home.file-mutable.codex-settings = lib.mkIf (cfg.settings != { }) {
        inherit (cfg) enable;
        extraConfig = builtins.readFile config.home.file."/${settings_path}".source;
        format = "toml";
        target = settings_path;
      };
    };
}
