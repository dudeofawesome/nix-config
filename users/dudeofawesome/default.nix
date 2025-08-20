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
        tmpl = config.sops.placeholder;

        scrutiny_path = "users/dudeofawesome/scrutiny-api";

        tokens_path = "users/dudeofawesome/nix_access_tokens";
        github_path = "github.com";
      in
      {
        sops = {
          secrets."${scrutiny_path}/endpoint/cluster/schema" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };
          secrets."${scrutiny_path}/endpoint/cluster/origin" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };
          secrets."${scrutiny_path}/endpoint/external/schema" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };
          secrets."${scrutiny_path}/endpoint/external/origin" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };
          secrets."${scrutiny_path}/username" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };
          secrets."${scrutiny_path}/password" = {
            sopsFile = ./secrets.yaml;
            # owner = config.launchd.daemons.scrutiny-collector.serviceConfig.UserName;
          };

          templates."scrutiny-endpoint".content = lib.concatStrings [
            "${tmpl."${scrutiny_path}/endpoint/external/schema"}://"
            "${tmpl."${scrutiny_path}/username"}:${tmpl."${scrutiny_path}/password"}@"
            "${tmpl."${scrutiny_path}/endpoint/external/origin"}"
          ];

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
