{ os, username, config, osConfig, pkgs, ... }:
let
  user = osConfig.users.users.${config.home.username};
in
{
  sops =
    let
      secrets_base =
        if pkgs.stdenv.targetPlatform.isLinux
        then "/run/user/${config.home.username}"
        else if pkgs.stdenv.targetPlatform.isDarwin
        then "/tmp/sops-secrets/${config.home.username}"
        else abort;
    in
    {
      age.keyFile =
        if pkgs.stdenv.targetPlatform.isLinux
        then "/home/${config.home.username}/.config/sops/age/keys.txt"
        else if pkgs.stdenv.targetPlatform.isDarwin
        then "/Users/${config.home.username}/Library/Application Support/sops/age/keys.txt"
        else abort;

      defaultSymlinkPath = "${secrets_base}/secrets";
      defaultSecretsMountPoint = "${secrets_base}/secrets.d";
    };
}
