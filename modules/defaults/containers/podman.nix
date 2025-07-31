{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;

  nvidia_enable = builtins.elem "nvidia" config.boot.kernelModules;
in
{
  environment.systemPackages =
    with pkgs;
    lib.flatten [
      podman
    ];

  virtualisation.podman = lib.mkIf isLinux {
    enable = true;
  };

  hardware = lib.mkIf isLinux {
    nvidia-container-toolkit.enable = nvidia_enable;
  };
  services = lib.mkIf isLinux {
    xserver.enable = true;
  };
}
