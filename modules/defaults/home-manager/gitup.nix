{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."co.gitup.mac" = {
        GIPreferences_TerminalTool = "iTerm";
        DiffWhitespaceMode = 1;
      };
    };
  };
}
