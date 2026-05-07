{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.postico;
in
{
  options = {
    programs.postico = {
      enable = lib.mkEnableOption "Postico PostgreSQL client";

      package = lib.mkPackageOption pkgs "Postico PostgreSQL client" {
        default = [ "postico" ];
      };

      settings = lib.mkOption {
        description = "Defaults to write for Postico.";
        type = lib.types.attrs;
        default = {
          AlternatingRows = true;
          DontSortRows = false;
          IndentWithSpaces = true;
          TabWidth = 2;
          NSFixedPitchFont = "FiraCodeNFM-Reg";
          TableViewFontFixedWidth = true;
          AutomaticallyUppercaseSQLKeywords = true;
          OpenNewTabStrategy = 1;
        };
        example = {
          TabWidth = 4;
          OpenNewTabStrategy = 0;
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.packages = [ cfg.package ];

    targets.darwin.defaults."at.eggerapps.Postico" = cfg.settings;
  };
}
