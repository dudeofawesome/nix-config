{ config, pkgs, ... }: {
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/vm.nix
  ];

  users.users.dudeofawesome = {
    home = "/home/dudeofawesome";
    shell = pkgs.fish;
  };

  networking = {
    hostName = "crater-lake-vm";
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
