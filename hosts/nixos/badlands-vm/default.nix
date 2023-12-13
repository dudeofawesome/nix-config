{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
    ../../../modules/boot/systemd-boot.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/local-vm.nix
    ../../../users/dudeofawesome/os/linux.nix
  ];

  networking = {
    hostName = "badlands-vm";
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
