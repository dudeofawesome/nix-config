{ ... }: {
  imports = [
    ./awscli.nix
    ./clock.nix
    ./dock.nix
    ./moar.nix
    ./process-compose.nix
  ];
}
