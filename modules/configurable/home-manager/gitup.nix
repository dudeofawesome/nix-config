{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.gitup;
in
{
  options = {
    programs.gitup = {
      enable = lib.mkEnableOption "GitUp desktop app";

      package = lib.mkPackageOption pkgs "Git client" {
        default = [ "gitup" ];
      };

      externalTerminal = lib.mkOption {
        description = "How whitespace is rendered in diffs.";
        type = lib.types.enum [
          "Terminal"
          "iTerm"
        ];
        default = "Terminal";
        example = "Terminal";
      };

      diffGeneration = lib.mkOption {
        description = "How whitespace is rendered in diffs.";
        type = lib.types.enum [
          "includeAllWhitespace"
          "ignoreWhitespaceAmount"
          "ignoreAllWhitespace"
        ];
        default = "ignoreWhitespaceAmount";
        example = "ignoreWhitespaceAmount";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    targets.darwin = {
      defaults."co.gitup.mac" = {
        GIPreferences_TerminalTool = cfg.externalTerminal;
        DiffWhitespaceMode =
          {
            "includeAllWhitespace" = 0;
            "ignoreWhitespaceAmount" = 1;
            "ignoreAllWhitespace" = 2;
          }
          ."${cfg.diffGeneration}";
      };
    };
  };
}
