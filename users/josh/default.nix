{
  config = {
    linux = {
      sops.secrets."users/josh/hashedPassword" = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
    };
  };
  user = {
    fullName = "Josh Gibbs";
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWpH2swLUhFYS8ffRP7bviAwTroqaCACeAcp6kAtyO0" ];
  };
  home-manager = import ./home-manager;
}
