{ ... }:
{
  imports = [
    ./hosts.darwin.nix
    ./homebrew.darwin.nix
    ./scrutiny-collector.darwin.nix
    ./containers/podman.darwin.nix
  ];
}
