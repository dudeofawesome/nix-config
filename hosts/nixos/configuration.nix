{ ... }: {
  imports = [
    ../../modules/auth.nix
  ];

  system = {
    stateVersion = "23.05";
  };
}
