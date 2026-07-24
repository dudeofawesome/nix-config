{
  pkgs,
  lib,
  config,
  machine-class,
  os,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;

  nvidia_enable = config.hardware.nvidia.enabled;
in
{
  config = {
    environment.systemPackages = with pkgs; [
      podman
    ];

    virtualisation.podman = {
      enable = true;
      desktop.enable = lib.mkDefault (machine-class == "pc" || isDarwin);
    };
  }
  // lib.optionalAttrs (os == "linux") {
    hardware = {
      nvidia-container-toolkit.enable = nvidia_enable;
    };
    # services = {
    #   # TODO: why does podman need xserver?
    #   xserver.enable = nvidia_enable;
    # };
  };
}
