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
        tokens = "users/dudeofawesome/nix_access_tokens";
        tmpl = config.sops.placeholder;

        tokens_path = "users/dudeofawesome/nix_access_tokens";
        github_path = "github.com";
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
          in
          lib.concatStrings [
            "${tmpl."${scrutiny}/endpoint/external/schema"}://"
            "${tmpl."${scrutiny}/username"}:${tmpl."${scrutiny}/password"}@"
            "${tmpl."${scrutiny}/endpoint/external/origin"}"
          ];

        sops.secrets."${tokens}_github.com".sopsFile = ./secrets.yaml;
        sops.templates.${tokens} = {
          # owner = ;
          mode = "0440";
          content =
            let
              tmpl = config.sops.placeholder;
            in
            lib.concatStrings [
              "extra-access-tokens = github.com=${tmpl."${tokens}_github.com"}"
            ];
        };

        sops = {
          secrets."${tokens_path}/${github_path}".sopsFile = ./secrets.yaml;
          templates."${tokens_path}" = {
            # owner = ;
            # file must be accessible (r) to all users, because only the build daemon runs as root and not nix evaluator itself(?)
            mode = "0444";
            content = lib.concatStrings [
              "extra-access-tokens = github.com=${tmpl."${tokens_path}/${github_path}"}"
            ];
          };
        };
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
