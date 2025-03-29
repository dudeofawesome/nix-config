# TODO: https://docs.k3s.io/advanced#nvidia-container-runtime-support
# TODO: create k8s user accounts with certs: https://cloudhero.io/creating-users-for-your-kubernetes-cluster/

{
  pkgs,
  lib,
  config,
  ...
}:
let
  # https://github.com/NixOS/nixpkgs/pull/176520
  # k3s = pkgs.k3s.overrideAttrs
  #   (old: rec { buildInputs = old.buildInputs ++ [ pkgs.ipset ]; });
  multi-node = config.services.k3s.token != null;
  ha = config.services.k3s.clusterInit != null;
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
      configPath = pkgs.writers.writeYAML "k3s-config.yaml" {
        # tls-san = [
        #   "k8s.orleans.io"
        # ];

        flannel-backend = "host-gw";
        container-runtime-endpoint = "unix:///run/containerd/containerd.sock";
      };
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
  };

  # k8s doesn't work with nftables, so we need to revert to iptables.
  networking = {
    nftables.enable = false;
    firewall = {
      package = pkgs.iptables-legacy;

      allowedTCPPorts = lib.flatten [
        6443 # k8s API server
        # required if using a "High Availability Embedded etcd" configuration
        (lib.optionals (ha) [
          2379 # etcd clients
          2380 # etcd peers
        ])
      ];

      allowedUDPPorts =
        # required if using a "High Availability Embedded etcd" configuration
        lib.optionals (multi-node) [
          8472 # k3s, flannel:
        ];
    };

    networkmanager.dns = "dnsmasq";
  };
}
