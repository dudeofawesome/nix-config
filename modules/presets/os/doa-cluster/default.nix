{ lib, config, ... }:
{
  sops =
    let
      tmpl = config.sops.placeholder;

      tailscale_path = "users/dudeofawesome/tailscale";
    in
    {
      secrets."kubernetes/doa-cluster/tokens/server".sopsFile = ./secrets.yaml;

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

  services.k3s.tokenFile = config.sops.secrets."kubernetes/doa-cluster/tokens/server".path;
}
