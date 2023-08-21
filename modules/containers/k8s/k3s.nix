{ config, pkgs, epkgs, ... }:
let
  # https://github.com/NixOS/nixpkgs/pull/176520
  k3s = pkgs.k3s.overrideAttrs
    (old: rec { buildInputs = old.buildInputs ++ [ pkgs.ipset ]; });
in
{
  environment.systemPackages = with pkgs; [
    crun
    iptables-legacy
    fluxcd
    helmsman
    k3s
    kubectl
    kubernetes-helm
    kubeseal
  ];

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs; [
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in
      {
        plugins."io.containerd.grpc.v1.cri" = {
          # TODO: this may or may not be upstreamed already
          cni = {
            bin_dir = "${fullCNIPlugins}/bin";
            conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
          };
        };
      };
  };

  services.k3s = {
    # https://github.com/NixOS/nixpkgs/pull/176520
    package = k3s;
    enable = true;
    role = "server";
    # docker = true;
    extraFlags = toString [
      "--flannel-backend=host-gw"
      "--container-runtime-endpoint unix:///run/containerd/containerd.sock"
    ];
  };

  systemd.services.k3s = {
    wants = [
      "containerd.service"
      "network-online.target"
    ];
    after = [ "containerd.service" ];
  };

  # k8s doesn't work with nftables
  networking.nftables.enable = false;
  networking.firewall = {
    package = pkgs.iptables-legacy;

    allowedTCPPorts = [
      6443 # k8s API server
    ];
    # allowedUDPPorts = [ ... ];
  };
}
