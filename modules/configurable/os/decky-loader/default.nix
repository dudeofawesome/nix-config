{
  lib,
  pkgs,
  config,
  options,
  os,
  ...
}:
let
  has_decky = options ? jovian.decky-loader.enable;
in
{
  imports = lib.optionals (os == "linux") [ ./plugins ];

  options = lib.optionalAttrs (os == "linux") {
    jovian.decky-loader.modules = lib.mkOption {
      type = lib.types.submodule {
        # TODO: decky-wine-cellar, MusicControl
        options = {
          css-loader = {
            enable = lib.mkEnableOption "css-loader";
            package = lib.mkPackageOption pkgs "sdh-css-loader" {
              default = [ "sdh-css-loader" ];
            };
          };
          launch-options = {
            enable = lib.mkEnableOption "launch-options";
            package = lib.mkPackageOption pkgs "decky-launch-options" {
              default = [ "decky-launch-options" ];
            };
          };
          ludusavi = {
            enable = lib.mkEnableOption "ludusavi";
            package = lib.mkPackageOption pkgs "decky-ludusavi" {
              default = [ "decky-ludusavi" ];
            };
          };
          magicpods = {
            enable = lib.mkEnableOption "magicpods";
            package = lib.mkPackageOption pkgs "magicpods-decky" {
              default = [ "magicpods-decky" ];
            };
          };
          pause-games = {
            enable = lib.mkEnableOption "pause-games";
            package = lib.mkPackageOption pkgs "sdh-pause-games" {
              default = [ "sdh-pause-games" ];
            };
          };
          protondb-decky = {
            enable = lib.mkEnableOption "protondb-decky";
            package = lib.mkPackageOption pkgs "protondb-decky" {
              default = [ "protondb-decky" ];
            };
          };
          steamback = {
            enable = lib.mkEnableOption "steamback";
            package = lib.mkPackageOption pkgs "steamback" {
              default = [ "steamback" ];
            };
          };
          steamgriddb = {
            enable = lib.mkEnableOption "steamgriddb";
            package = lib.mkPackageOption pkgs "decky-steamgriddb" {
              default = [ "decky-steamgriddb" ];
            };
          };
          tabmaster = {
            enable = lib.mkEnableOption "tabmaster";
            package = lib.mkPackageOption pkgs "tabmaster" {
              default = [ "tabmaster" ];
            };
          };
        };
      };
      default = { };
      example = lib.literalExpression ''
        { steamback.enable = true; };
      '';
    };

    jovian.decky-loader.plugins = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression ''
        [ pkgs.steamback ];
      '';
    };
  };

  config = lib.optionalAttrs (os == "linux") (
    let
      cfg = config.jovian.decky-loader;
      pluginsDir = pkgs.linkFarm "decky-loader-plugins" (
        map (pkg: {
          name = pkg.pname or (lib.getName pkg);
          path = pkg;
        }) cfg.plugins
      );
    in
    lib.mkIf (has_decky && cfg.enable) {
      jovian.decky-loader.plugins = lib.pipe cfg.modules [
        (lib.filterAttrs (name: mod: mod.enable))
        (lib.mapAttrsToList (name: mod: mod.package))
      ];

      systemd.services.decky-loader = {
        restartTriggers = [ pluginsDir ];
        path = lib.concatMap (pkg: pkg.runtimeDependencies or [ ]) cfg.plugins;

        environment = {
          CHOWN_PLUGIN_PATH = "0";
          LD_LIBRARY_PATH = lib.makeLibraryPath config.systemd.services.decky-loader.path;
        };

        preStart = lib.mkAfter ''
          ${lib.concatMapStrings (
            pkg:
            let
              pluginName = pkg.pname or (lib.getName pkg);
            in
            ''
              for stateDir in settings data logs; do
                versionedStateDir="${cfg.stateDir}/$stateDir/${pkg.name}"
                stableStateDir="${cfg.stateDir}/$stateDir/${pluginName}"

                if [ -d "$versionedStateDir" ] && [ ! -e "$stableStateDir" ]; then
                  mv -- "$versionedStateDir" "$stableStateDir"
                fi
              done
            ''
          ) cfg.plugins}

          pluginsDir="${cfg.stateDir}/plugins"

          rm -rf -- "$pluginsDir"
          ln -s ${pluginsDir} "$pluginsDir"
        '';
      };
    }
  );
}
