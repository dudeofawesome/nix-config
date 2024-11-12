{ pkgs, os, ... }:
let doa-lib = import ../../lib; in
{
  imports = [
    (doa-lib.try-import ./server.${os}.nix)
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
