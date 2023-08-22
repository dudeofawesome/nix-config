{ lib, pkgs, users, ... }:
{
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/pc.nix
  ];

  networking = {
    hostName = "badlands";
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
