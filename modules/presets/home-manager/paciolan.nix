{ os, hostname, pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  home.packages = with pkgs; [
    # Utilities
    ansible
    awscli2
    glab
    gitlab-runner
    terraform
  ];
}
