{ ... }: {
  imports = [
    ../../modules/auth.linux.nix
  ];

  system = {
    stateVersion = "23.05";
  };
}
