{ pkgs, ... }:
{
  imports = [
  ];

  environment = {
    systemPackages = with pkgs; [
      k6
      zoom-us
    ];
  };

  homebrew = {
    casks = [
      "google-earth-pro"
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
