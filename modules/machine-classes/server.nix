{ pkgs, os, ... }:
{
  imports = [
    (if (builtins.pathExists ./server.${os}.nix) then ./server.${os}.nix else { })
    ../defaults/containers/docker.nix
    ../defaults/containers/podman.nix
    ../defaults/containers/k8s/k3s.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      lynx
      ncdu
    ];
  };
}
