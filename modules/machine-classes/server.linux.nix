{ ... }:
{
  imports = [
    ../defaults/containers/docker.nix
    ../defaults/containers/podman.nix
    ../defaults/containers/k8s/k3s.nix
  ];
}
