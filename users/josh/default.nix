{ ... }: {
  fullName = "Louis Orleans";
  settings = import ./home-manager;
  # openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
}
