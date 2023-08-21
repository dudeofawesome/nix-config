{ pkgs, ... }:
{
  imports = [
    ../containers/docker.nix
    ../containers/podman.nix
    ../containers/k8s/k3s.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      lynx
      ncdu
    ];
  };
}
