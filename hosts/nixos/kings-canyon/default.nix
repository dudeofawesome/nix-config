{ config, pkgs, ... }: {
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/server.nix
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
