{
  lib,
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
    lib.mkIf (has_jovian && cfg.enable && cfg.plugins != [ ]) {
      systemd.services.decky-loader = {
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
