{ ... }: {
  fullName = "Josh Gibbs";
  home-manager = import ./home-manager;
  openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWpH2swLUhFYS8ffRP7bviAwTroqaCACeAcp6kAtyO0" ];
}
