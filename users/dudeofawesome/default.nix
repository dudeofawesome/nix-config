{}: {
  config = {
    sops.secrets.${"users/dudeofawesome/hashedPassword"} = {
      sopsFile = ./secrets.yaml;
      neededForUsers = true;
    };
  };
  user = {
    fullName = "Louis Orleans";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD3VYzXLFPEC25hK7o5+NrV9cvNlyV7Y93UyAQospbw" ];
  };
  home-manager = import ./home-manager;
}
