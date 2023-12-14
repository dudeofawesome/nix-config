{ config, pkgs, ... }: {
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.linux.nix
    ../../../modules/machine-classes/server.nix
    ../../../users/dudeofawesome/os/linux.nix
  ];

  users.users.dudeofawesome = {
    home = "/home/dudeofawesome";
    shell = pkgs.fish;
  };

  networking = {
    hostName = "kings-canyon";
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
