{ config, pkgs, ... }: {
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/pc.nix
  ];

  users.users.dudeofawesome = {
    home = "/Users/dudeofawesome";
    shell = pkgs.fish;
  };

  networking = {
    hostName = "crater-lake";
  };

  environment = {
    systemPackages = with pkgs; [
      k6
    ];
  };

  homebrew = {
    casks = [
      "zoom"
    ];
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "nix-builder";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
      }
    ];
  };
}
