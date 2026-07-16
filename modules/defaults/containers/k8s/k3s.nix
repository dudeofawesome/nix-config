# TODO: https://docs.k3s.io/advanced#nvidia-container-runtime-support
# TODO: create k8s user accounts with certs: https://cloudhero.io/creating-users-for-your-kubernetes-cluster/

{
  pkgs,
  lib,
  config,
  owner,
  ...
}:
let
  # https://github.com/NixOS/nixpkgs/pull/176520
  # k3s = pkgs.k3s.overrideAttrs
  #   (old: rec { buildInputs = old.buildInputs ++ [ pkgs.ipset ]; });
  multi-node =
    config.services.k3s.token != ""
    || config.services.k3s.tokenFile != null
    || config.services.k3s.serverAddr != "";
  server = config.services.k3s.role == "server";
  embedded-etcd-node =
    server && (config.services.k3s.clusterInit || config.services.k3s.serverAddr != "");

  k3s-config = {
    container-runtime-endpoint = "unix:///run/containerd/containerd.sock";
  }
  // lib.optionalAttrs server {
    # tls-san = [
    #   "k8s.orleans.io"
    # ];

    disable = [ "traefik" ];
    flannel-backend = if multi-node then "wireguard-native" else "host-gw";
  };
in
{
  imports = [
    ./user-utils.nix
  ];

  environment.systemPackages = with pkgs; [
    crun
    iptables-legacy
    k3s
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

  services = {
    k3s = {
      # https://github.com/NixOS/nixpkgs/pull/176520
      # package = k3s;
      enable = true;
      role = lib.mkDefault "server";
      # tokenFile = config.sops.
      configPath = pkgs.writers.writeYAML "k3s-config.yaml" k3s-config;

      extraFlags = lib.flatten [
        (lib.optional (config.sops.templates ? "k3s-vpn-auth-file") ''
          --vpn-auth-file=${config.sops.templates.k3s-vpn-auth-file.path}
        '')
      ];
    };

    dnsmasq = {
      enable = true;
      settings = {
        # use CoreDNS to resolve cluster resources
        server = [ "/cluster.local/10.42.0.8" ];
      };
    };
  };
  systemd.services.k3s = {
    wants = [
      "containerd.service"
      "network-online.target"
    ];
    after = [ "containerd.service" ];

    path = [
      pkgs.tailscale
    ];
  };

  # k8s doesn't work with nftables, so we need to revert to iptables.
  networking = {
    nftables.enable = false;
    firewall = {
      package = pkgs.iptables-legacy;

      allowedTCPPorts = lib.flatten [
        10250 # kubelet metrics and API
        (lib.optional server 6443) # k8s API server
        # required if using a "High Availability Embedded etcd" configuration
        (lib.optionals embedded-etcd-node [
          2379 # etcd clients
          2380 # etcd peers
        ])
      ];

      allowedUDPPorts =
        # Flannel's WireGuard backend on multi-node IPv4 clusters.
        lib.optionals (multi-node) [
          51820
        ];
    };

    networkmanager.dns = "dnsmasq";
  };
}
