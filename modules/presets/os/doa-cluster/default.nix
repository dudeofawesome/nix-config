{
  lib,
  config,
  ...
}:
let
  agent-token-path = "kubernetes/doa-cluster/tokens/agent";
  server-token-path = "kubernetes/doa-cluster/tokens/server";
  # The Pi has ~1 GiB RAM; the main node has ~94 GiB. These are caps,
  # not reservations. Revisit alongside workload count and log volume.
  pod-log-tmpfs-size = if config.networking.hostName == "capitol-reef" then "64M" else "512M";
in
{
  sops =
    let
      tmpl = config.sops.placeholder;

      tailscale_path = "users/dudeofawesome/tailscale";
    in
    {
      secrets.${agent-token-path}.sopsFile = ./secrets.yaml;
      secrets.${server-token-path}.sopsFile = ./secrets.yaml;

      secrets."${tailscale_path}/auth_key".sopsFile = ../../../../users/dudeofawesome/secrets.yaml;
      templates.k3s-vpn-auth-file =
        let
          commaSepAttrs =
            attr:
            lib.pipe attr [
              (lib.mapAttrsToList (key: value: "${key}=${value}"))
              (lib.concatStringsSep ",")
            ];
        in
        {
          # owner = ;
          # mode = "0444";
          content = commaSepAttrs {
            name = "tailscale";
            joinKey = tmpl."${tailscale_path}/auth_key";
          };
        };

    };

  # Activate this mount through a boot generation and reboot, not a live
  # switch: containerd shims may otherwise keep writing to hidden disk files.
  fileSystems."/var/log/pods" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "mode=0755"
      "nosuid"
      "nodev"
      "noexec"
      "noswap"
      "size=${pod-log-tmpfs-size}"
    ];
  };

  # This cluster uses a separate containerd service. Both it and K3s must
  # wait for the mount, and must not start if it cannot be mounted.
  systemd.services.containerd.unitConfig.RequiresMountsFor = [ "/var/log/pods" ];
  systemd.services.k3s.unitConfig.RequiresMountsFor = [ "/var/log/pods" ];

  services.k3s = {
    extraFlags = [
      "--kubelet-arg=container-log-max-size=1Mi"
      "--kubelet-arg=container-log-max-files=2"
    ];
    tokenFile =
      config.sops.secrets.${
        if config.services.k3s.role == "agent" then agent-token-path else server-token-path
      }.path;
    agentTokenFile = lib.mkIf (config.services.k3s.role == "server") (
      config.sops.secrets.${agent-token-path}.path
    );
  };
}
