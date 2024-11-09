{ os, ... }: {
  imports = [
    ./keyboard.nix
    ./sops.nix
    ./nix.nix
  ];
}
