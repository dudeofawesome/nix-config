{ config, pkgs, ... }: {
  imports = [
    ../../../modules/defaults/fs/zfs.nix
    ../../../modules/defaults/fs/bcachefs.nix
  ];

  networking = {
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };
}
