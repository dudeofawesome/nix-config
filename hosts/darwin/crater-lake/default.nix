{ hostname, pkgs, ... }:
{
  imports = [
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
