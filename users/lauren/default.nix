{
  user = {
    fullName = "Lauren";
    openssh.authorizedKeys.keys = [ ];
  };
  os = {
    linux =
      { config, ... }:
      {
        sops.secrets."users/lauren/hashedPassword" = {
          sopsFile = ./secrets.yaml;
          neededForUsers = true;
        };
      };
  };
  home-manager = import ./home-manager;
}
