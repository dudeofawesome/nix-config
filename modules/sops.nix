{ pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  environment = {
    systemPackages = with pkgs; [
      age
      sops
      ssh-to-age
    ];
  };
}
