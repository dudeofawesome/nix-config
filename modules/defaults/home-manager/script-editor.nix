{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.apple.ScriptEditor2" = {
        UsesScriptAssistant = true;
        TabWidth = 2;
        IndentWidth = 2;
      };
    };
  };
}
