{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkPackageOption
    ;
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
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
      };

      # TODO: consider `dockerCompat`, `dockerSocket`
      # TODO: consider `autoPrune`
    };

  };
  config =
    let
      cfg = config.virtualisation.podman;
    in
    mkIf (isDarwin && cfg.enable) {
      environment.systemPackages = lib.flatten [
        cfg.package
        (lib.optional cfg.desktop.enable cfg.desktop.package)
      ];
    };
}
