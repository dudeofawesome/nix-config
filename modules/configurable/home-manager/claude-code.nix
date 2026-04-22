{ lib, config, ... }:
{
  config =
    let
      cfg = config.programs.claude-code;
    in
    {
      home.file.".claude/settings.json".enable = lib.mkForce false;
      home.file-json.claude-code-settings = lib.mkIf (cfg.settings != { }) {
        inherit (cfg) enable;
        extraConfig = builtins.readFile config.home.file.".claude/settings.json".source;
        target = ".claude/settings.json";
      };
    };
}
