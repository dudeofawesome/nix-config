{ lib, config, ... }:
{
  options =
    let
      inherit (lib) mkOption;
    in
    {
      programs.claude-code = {
        mutableSettings = mkOption {
          type = lib.types.bool;
          default = true;
        };
      };
    };

  config =
    let
      cfg = config.programs.claude-code;
      settings_path = ".claude/settings.json";
    in
    lib.mkIf (cfg.mutableSettings) {
      home.file.${settings_path}.enable = lib.mkForce false;
      home.file-mutable.claude-code-settings = lib.mkIf (cfg.settings != { }) {
        inherit (cfg) enable;
        extraConfig = builtins.readFile config.home.file.${settings_path}.source;
        format = "json";
        target = settings_path;
      };
    };
}
