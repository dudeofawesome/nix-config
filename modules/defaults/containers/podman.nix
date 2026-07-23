{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;

  # nvidia_enable = builtins.elem "nvidia" config.boot.kernelModules;
  # nvidia_enable = builtins.elem "nvidia" config.services.xserver.videoDrivers;
  # nvidia_enable = config.hardware.graphics.enable && config.;
  nvidia_enable = config.hardware.nvidia.enabled;
in
{
  config = {
    environment.systemPackages = with pkgs; [
      podman
    ];
  }
  // lib.mkIf isLinux {
    virtualisation.podman = {
      enable = true;
    };

    hardware = {
      nvidia-container-toolkit.enable = nvidia_enable;
    };
    # services = {
    #   # TODO: why does podman need xserver?
    #   xserver.enable = nvidia_enable;
    # };
  };
}
