{
  lib,
  pkgs,
  config,
  options,
  os,
  ...
}:
let
  has_jovian = options ? jovian.enable;
in
{
  options = lib.optionalAttrs (os == "linux") {
    jovian.decky-loader.modules = lib.mkOption {
      type = lib.types.submodule {
        options = {
          launch-options = {
            enable = lib.mkEnableOption "launch-options";
            package = lib.mkPackageOption pkgs "decky-launch-options" {
              default = [ "decky-launch-options" ];
            };
          };
          steamback = {
            enable = lib.mkEnableOption "steamback";
            package = lib.mkPackageOption pkgs "steamback" {
              default = [ "steamback" ];
            };
          };
          themedeck = {
            enable = lib.mkEnableOption "themedeck";
            package = lib.mkPackageOption pkgs "themedeck" {
              default = [ "themedeck" ];
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
    in
    lib.mkIf (has_jovian && cfg.enable) {
      jovian.decky-loader.plugins = lib.pipe cfg.modules [
        (lib.filterAttrs (name: mod: mod.enable))
        (lib.mapAttrsToList (name: mod: mod.package))
      ];

      systemd.services.decky-loader = lib.mkIf (cfg.plugins != [ ]) {
        restartTriggers = cfg.plugins;

        preStart = lib.mkAfter (
          map (pkg: ''
            pluginDir="${config.jovian.decky-loader.stateDir}/plugins/${pkg.name}"

            rm -rf -- "$pluginDir"
            install -d -m 0755 "$pluginDir"
            cp -R ${pkg}/. "$pluginDir/"
            chown -R "${config.jovian.decky-loader.user}:" "$pluginDir"
            chmod -R u+w "$pluginDir"
          '') cfg.plugins
        );
      };
    }
  );
}
