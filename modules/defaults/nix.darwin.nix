{ lib, ... }:
{
  nix = {
    linux-builder = {
      enable = lib.mkDefault true;
      config.virtualisation.cores = lib.mkDefault 4;
    };
  };

  # Auto-upgrade daemon
  services.nix-daemon.enable = lib.mkDefault true;
}
