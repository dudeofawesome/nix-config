{ users, lib, pkgs, ... }:
with lib;
with pkgs.stdenv.targetPlatform;
{
  users = {
    users = builtins.mapAttrs
      (key: val: {
        description = val.fullName;

        home = "/${if isLinux then "home" else "Users"}/${key}";
        shell = if (val ? shell) then pkgs."${val.shell}" else pkgs.fish;

        openssh.authorizedKeys.keys = val.openssh.authorizedKeys.keys;
      })
      users;
  };
}
