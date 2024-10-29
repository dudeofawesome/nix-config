{ ... }: {
  imports = [
    ./awscli.nix
    ./dock.nix
    ./moar.nix
    ./process-compose.nix
  ];
}
