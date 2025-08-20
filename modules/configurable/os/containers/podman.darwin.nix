{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    mkEnableOption
    mkPackageOption
    types
    ;
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;
in
{
  meta = {
    maintainers = [ "dudeofawesome" ];
  };

  options = {
    virtualisation.podman = {
      enable = mkEnableOption "podman";
      package = mkPackageOption pkgs "podman" { };

      desktop = {
        enable = mkEnableOption "podman-desktop";
        package = mkPackageOption pkgs "podman-desktop" { };
        package-darwin = mkOption {
          type = types.str;
          default = "podman-desktop";
        };
      };

      # TODO: consider `dockerCompat`, `dockerSocket`
      # TODO: consider `autoPrune`
    };

  };
  config =
    let
      cfg = config.virtualisation.podman;
    in
    mkIf isDarwin {
      environment.systemPackages =
        with pkgs;
        lib.flatten [
          cfg.package
          (lib.optional cfg.desktop.enable [
            (lib.optional isLinux cfg.desktop.package)
            (lib.optional isDarwin pkgs.podman-mac-helper)
          ])
        ];

      homebrew.casks = lib.mkIf (isDarwin && cfg.desktop.enable) [ cfg.desktop.package-darwin ];
    };
}
