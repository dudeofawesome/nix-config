{ pkgs, lib, os, hostname, machine-class, ... }:
with pkgs.stdenv.targetPlatform;
{
  home.packages = with pkgs; [
    # Utilities
    awscli2
    glab
    k6
    terraform
  ] ++ (if (machine-class == "pc") then [
    ansible
    gitlab-runner
    postman
    slack
    tableplus
    zoom-us
  ] else [ ]);
}
