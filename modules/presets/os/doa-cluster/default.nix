{
  lib,
  config,
  ...
}:
let
  agent-token-path = "kubernetes/doa-cluster/tokens/agent";
  server-token-path = "kubernetes/doa-cluster/tokens/server";
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

  services.k3s = {
    tokenFile =
      config.sops.secrets.${
        if config.services.k3s.role == "agent" then agent-token-path else server-token-path
      }.path;
    agentTokenFile = lib.mkIf (config.services.k3s.role == "server") (
      config.sops.secrets.${agent-token-path}.path
    );
  };
}
