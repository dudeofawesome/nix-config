{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    fluxcd
    helmsman
    kubectl
    kubectx
    kubernetes-helm
    kubeseal
  ];
}
