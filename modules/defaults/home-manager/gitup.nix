{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    programs.gitup = {
      enable = true;

      externalTerminal = "iTerm";
      diffGeneration = "ignoreWhitespaceAmount";
    };
  };
}
