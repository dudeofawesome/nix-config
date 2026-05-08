{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.tableplus;
in
{
  options = {
    programs.tableplus = {
      enable = lib.mkEnableOption "TablePlus database client";

      package = lib.mkPackageOption pkgs "TablePlus database client" {
        default = [ "tableplus" ];
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          options = {
            SQLFontSize = lib.mkOption {
              type = lib.types.int;
              description = "";
              default = 12;
            };
            DataFontSize = lib.mkOption {
              type = lib.types.int;
              description = "";
              default = 12;
            };

            IndentType = lib.mkOption {
              # TODO: make enum
              type = lib.types.int;
              description = "";
              default = 0;
            };
            TabWidthSpaces = lib.mkOption {
              type = lib.types.int;
              description = "";
              default = 4;
            };
          };
        };
        default = { };
        description = "Configuration for TablePlus";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    targets.darwin = {
      defaults."com.tinyapp.TablePlus" = {
        ViewSetting = {
          SQLFontSize = cfg.settings.SQLFontSize;
          DataFontSize = cfg.settings.DataFontSize;
          IndentType = cfg.settings.IndentType;
          TabWidthSpaces = cfg.settings.TabWidthSpaces;
        };

        # updates
        SUEnableAutomaticChecks = false;
      };
    };
  };
}
