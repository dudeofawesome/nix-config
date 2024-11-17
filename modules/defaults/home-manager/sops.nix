{ pkgs, lib, os, config, osConfig, ... }:
with pkgs.stdenv.targetPlatform;
let
  user = osConfig.users.users.${config.home.username};
in
{
  sops =
    let
      secrets_base =
        if isLinux then
          "/run/user/${config.home.username}"
        else if isDarwin then
          "/tmp/sops-secrets/${config.home.username}"
        else abort;
    in
    {
      age.keyFile = lib.mkDefault (
        if isLinux then
          "${config.home.homeDirectory}/.config/sops/age/keys.txt"
        else if isDarwin then
          "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
        else abort
      );

      defaultSopsFile = let path = ../../../users/${config.home.username}/secrets.yaml; in
        lib.mkIf (builtins.pathExists path) path;

      defaultSymlinkPath = "${secrets_base}/secrets";
      defaultSecretsMountPoint = "${secrets_base}/secrets.d";
    };
}
