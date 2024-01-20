{ pkgs, lib, config, ... }:
let
  nvidia_enable = builtins.elem "nvidia" config.boot.kernelModules;
in
{
  environment.systemPackages = with pkgs; [
    podman
  ] ++ lib.optional nvidia_enable [ nvidia-podman ];

  virtualisation.podman = {
    enable = true;
    enableNvidia = nvidia_enable;
  };
}
