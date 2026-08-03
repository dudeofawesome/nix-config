{
  pkgs,
  lib,
  config,
  users,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  user = users.${config.home.username};
in
{
  sops = {
    age.keyFile = lib.mkDefault (
      if isLinux then
        "${config.home.homeDirectory}/.config/sops/age/keys.txt"
      else if isDarwin then
        "${config.home.homeDirectory}/Library/Application Support/sops/age/keys.txt"
      else
        abort
    );

    defaultSopsFile =
      let
        path = ../../../users/${user.original_name}/secrets.yaml;
      in
      lib.mkIf (builtins.pathExists path) path;

    # On Linux, keep sops-nix's defaults. They use /run/user/$UID; a path
    # based on the username is not an XDG runtime directory and cannot be
    # created by the user service.
    defaultSymlinkPath = lib.mkIf isDarwin "/tmp/sops-secrets/${config.home.username}/secrets";
    defaultSecretsMountPoint = lib.mkIf isDarwin "/tmp/sops-secrets/${config.home.username}/secrets.d";
  };
}
