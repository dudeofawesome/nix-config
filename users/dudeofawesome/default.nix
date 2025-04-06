{
  os = {
    linux =
      { config, ... }:
      {
        sops.secrets."users/dudeofawesome/hashedPassword" = {
          sopsFile = ./secrets.yaml;
          neededForUsers = true;
        };
      };
    default =
      { config, lib, ... }:
      let
        scrutiny = "users/dudeofawesome/scrutiny-api";
      in
      {
        sops.secrets."${scrutiny}/endpoint/cluster/schema" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${scrutiny}/endpoint/cluster/origin" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${scrutiny}/endpoint/external/schema" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${scrutiny}/endpoint/external/origin" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${scrutiny}/username" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${scrutiny}/password" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };

        sops.templates."scrutiny-endpoint".content =
          let
            tmpl = config.sops.placeholder;
            scrutiny = "users/dudeofawesome/scrutiny-api";
          in
          lib.concatStrings [
            "${tmpl."${scrutiny}/endpoint/external/schema"}://"
            "${tmpl."${scrutiny}/username"}:${tmpl."${scrutiny}/password"}@"
            "${tmpl."${scrutiny}/endpoint/external/origin"}"
          ];

        sops.secrets."users/dudeofawesome/nix_access_tokens/github.com".sopsFile = ./secrets.yaml;
        sops.templates."users/dudeofawesome/nix_access_tokens" = {
          mode = "0440";
          content =
            let
              tmpl = config.sops.placeholder;
              tokens = "users/dudeofawesome/nix_access_tokens";
            in
            lib.concatStrings [
              "extra-access-tokens = github.com=${tmpl."${tokens}/github.com"}"
            ];
        };
        nix.extraOptions = ''
          include ${config.sops.templates."users/dudeofawesome/nix_access_tokens".path}
        '';
      };
  };
  user = {
    fullName = "Louis Orleans";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD3VYzXLFPEC25hK7o5+NrV9cvNlyV7Y93UyAQospbw"
    ];
  };
  home-manager = import ./home-manager;
}
