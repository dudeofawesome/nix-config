{ ... }:
{
  imports = [
    ./samba-users.nix
    ./time-machine-server.nix
    ./headful/gnome.nix
  ];
}
