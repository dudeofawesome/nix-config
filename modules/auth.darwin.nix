{ users, pkgs, ... }:
with pkgs.stdenv.targetPlatform;
let
  userSettings = (builtins.mapAttrs (key: val: val.user) users);
in
{
  users = {
    users = builtins.mapAttrs
      (key: val: {
        description = val.fullName;

        home = "/${if isLinux then "home" else "Users"}/${key}";
        shell = if (val ? shell) then pkgs."${val.shell}" else pkgs.fish;

        openssh.authorizedKeys.keys = val.openssh.authorizedKeys.keys;
      })
      userSettings;
  };
}
