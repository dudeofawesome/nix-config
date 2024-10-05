{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."at.eggerapps.Postico" = {
        AlternatingRows = true;
        DontSortRows = false;
        IndentWithSpaces = true;
        TabWidth = 2;
        NSFixedPitchFont = "FiraCodeNFM-Reg";
        TableViewFontFixedWidth = true;
        AutomaticallyUppercaseSQLKeywords = true;
        OpenNewTabStrategy = 1;
      };
    };
  };
}
