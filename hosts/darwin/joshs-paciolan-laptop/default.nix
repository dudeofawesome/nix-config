{ pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/base.nix
    ../../../modules/machine-classes/pc.nix
    ../../../users/josh/darwin.nix
  ];

  homebrew = {
    casks = [
      "battery"
    ];
  };

  networking = {
    hostName = "joshs-paciolan-laptop";
  };

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      arduino-cli
      ffmpeg
      gitlab-runner
      imagemagick
      k6
      lynx
      nmap

      # Languages
      go
      go-outline
      gopls
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
