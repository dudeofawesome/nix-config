{ pkgs, lib, config, ... }:
{
  targets.darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
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
}
