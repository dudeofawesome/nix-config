{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  # TODO: `podman-mac-helper` bin is missing. When a custom `podman` bin is
  #   specified, podman-desktop doesn't automatically download the
  #   `podman-mac-helper` bin.
  #   https://podman-desktop.io/docs/troubleshooting/troubleshooting-podman-on-macos#unable-to-set-custom-binary-path-for-podman-on-macos

  options = {
    programs.podman-desktop = {
      enable = lib.mkEnableOption "podman-desktop";

      extraConfig = lib.mkOption {
        description = ''Extra config options for podman-desktop's settings.json'';
        type = lib.types.attrs;
        default = { };
        example = {
          "telemetry.enabled" = false;
          "preferences.login.start" = false;
        };
      };
    };
  };

  config =
    let
      inherit (pkgs.stdenv.targetPlatform) isDarwin;
      cfg = config.programs.podman-desktop;
      osCfg = osConfig.virtualisation.podman;
    in
    lib.mkIf cfg.enable {
      home.file-json.podman-desktop-settings = lib.mkIf (cfg.extraConfig != { }) {
        inherit (cfg) enable extraConfig;
        target =
          if (pkgs.stdenv.targetPlatform.isDarwin) then
            ".local/share/containers/podman-desktop/configuration/settings.json"
          else
            abort "unsupported OS ${pkgs.stdenv.targetPlatform.config}";
      };

      # point Podman Desktop to the podman-mac-helper bin
      xdg.configFile.podman-desktop-containers-conf = {
        enable = isDarwin;
        target = "containers/containers.conf";
        text =
          let
            # `lib.generators.toINI` doesn't support lists, so hack support for
            #   them by turning them into strings
            toINIWithLists = lib.generators.toINI {
              mkKeyValue =
                key: value:
                if builtins.isList value then
                  "${key}=[${lib.concatMapStringsSep "," (x: ''"${x}"'') value}]"
                else
                  lib.generators.mkKeyValueDefault { } key value;
            };
          in
          toINIWithLists {
            containers.helper_binaries_dir = [
              "${lib.getBin pkgs.podman-mac-helper}/bin"
            ];
            engine.env = [ "no_proxy=local,169.254/16" ];
            machine = { };
            network = { };
            secrets = { };
            configmaps = { };
          };
      };

      # TODO: should this be in the default value?
      programs.podman-desktop.extraConfig = {
        "podman.binary.path" = (lib.getExe osCfg.package);
      };
    };
}
