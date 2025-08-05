{ lib, ... }:
{
  nix = {
    linux-builder = {
      enable = lib.mkDefault false;
      config.virtualisation.cores = lib.mkDefault 4;
    };
  };
}
