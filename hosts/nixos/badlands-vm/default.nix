{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
    ../../../modules/boot/systemd-boot.nix
    ../../../modules/machine-classes/base.linux.nix
    ../../../modules/machine-classes/local-vm.nix
    ../../../modules/fs/zfs.nix
    ../../../users/dudeofawesome/os/linux.nix
  ];

  networking = {
    hostName = "badlands-vm";
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
