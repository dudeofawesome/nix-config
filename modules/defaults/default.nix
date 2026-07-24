{ os, ... }:
{
  imports = [
    ./keyboard.nix
    ./sops.nix
    ./nix.nix
    ./containers/podman.nix
  ];
}
