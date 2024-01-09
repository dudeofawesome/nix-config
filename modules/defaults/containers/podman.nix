{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nvidia-podman
    podman
  ];

  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
  };
}
