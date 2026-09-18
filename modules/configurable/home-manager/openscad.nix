{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
let
  cfg = config.programs.openscad;
in
{
  options = {
    programs.openscad = {
      enable = lib.mkEnableOption "OpenSCAD CAD software";

      package = lib.mkPackageOption pkgs-unstable "OpenSCAD CAD software" {
        default = [ "openscad-unstable" ];
      };

      libraries = lib.mkOption {
        description = ''
          OpenSCAD library packages to install. Packages must provide their
          libraries under `share/openscad/libraries`, preserving the directory
          names used by OpenSCAD include and use statements.
        '';
        type = with lib.types; listOf package;
        default = [
          pkgs.bosl
          pkgs.bosl2
        ];
      };

      libraryPath = lib.mkOption {
        type = lib.types.str;
        default =
          if pkgs.stdenv.isLinux then
            "${config.xdg.dataHome}/OpenSCAD/libraries"
          else if pkgs.stdenv.isDarwin then
            "Documents/OpenSCAD/libraries"
          else
            throw "Unsupported platform";
        description = ''
          Directory in which to install libraries, either absolute or relative
          to the home directory. Custom locations must be added to OpenSCAD's
          search path separately.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: set `OPENSCADPATH` to libraryPath

    home = {
      packages = [ cfg.package ];

      file.openscad-libraries = lib.mkIf (cfg.libraries != [ ]) {
        target = cfg.libraryPath;
        source = "${
          pkgs.buildEnv {
            name = "openscad-libraries";
            paths = cfg.libraries;
            pathsToLink = [ "/share/openscad/libraries" ];
          }
        }/share/openscad/libraries";
        recursive = true;
      };
    };
  };
}
