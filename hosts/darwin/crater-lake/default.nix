{ config, lib, ... }:
{
  imports = [
    ../../../modules/defaults/headful/gaming.darwin.nix
  ];

  homebrew = {
    casks = [
      "android-studio"
      "autodesk-fusion"
      "google-earth-pro"
    ];
  };

  nix = {
    distributedBuilds = lib.mkForce false;
    buildMachines = [
      {
        hostName = "linux-builder";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [
          "kvm"
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      devices = [ { device = "/dev/disk0"; } ];
    };
  };
}
