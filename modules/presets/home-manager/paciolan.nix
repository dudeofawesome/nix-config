{ pkgs, lib, os, hostname, machine-class, ... }:
with pkgs.stdenv.targetPlatform;
{
  home.packages = with pkgs; [
    # Utilities
    awscli2
    glab
    terraform
  ] ++ (if (machine-class == "pc") then [
    ansible
    gitlab-runner
    postman
    slack
    tableplus
  ] else [ ]);
}
