{ hostname, pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/pc.nix
    ../../../users/dudeofawesome/os/darwin.nix
  ];

  networking = {
    hostName = hostname;
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
