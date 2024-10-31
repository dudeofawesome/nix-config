{ os, hostname, pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  environment = {
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      # Utilities
      _1password-cli
      act
      ansible
      awscli2
      eternal-terminal
      vim-full
    ];
  };

  programs.fish.enable = true;
}
