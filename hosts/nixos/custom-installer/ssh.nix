{ lib, ... }:
let
  users = lib.pipe (builtins.readDir ../../../users) [
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrsToList (name: _: import (../../../users + "/${name}")))
  ];
in
{
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  users.users.nixos.openssh.authorizedKeys.keys = lib.pipe users [
    (map (user: user.user.openssh.authorizedKeys.keys))
    lib.flatten
  ];
}
