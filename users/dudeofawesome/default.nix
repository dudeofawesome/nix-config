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
        set = "users/dudeofawesome/scrutiny-api";
      in
      {
        sops.secrets."${set}/endpoint/cluster/schema" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${set}/endpoint/cluster/origin" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${set}/endpoint/external/schema" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${set}/endpoint/external/origin" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${set}/username" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };
        sops.secrets."${set}/password" = {
          sopsFile = ./secrets.yaml;
          # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
        };

        sops.templates."scrutiny-endpoint".content =
          let
            tmpl = config.sops.placeholder;
            set = "users/dudeofawesome/scrutiny-api";
          in
          lib.concatStrings [
            "${tmpl."${set}/endpoint/external/schema"}://"
            "${tmpl."${set}/username"}:${tmpl."${set}/password"}@"
            "${tmpl."${set}/endpoint/external/origin"}"
          ];
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
