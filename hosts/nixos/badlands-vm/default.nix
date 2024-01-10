{ config, pkgs, ... }: {
  imports = [
    ../../../modules/defaults/boot/systemd-boot.nix
    ../../../modules/defaults/fs/zfs.nix
  ];

  networking = {
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };
}
