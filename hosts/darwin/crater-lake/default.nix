{ config, ... }:
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

  determinateNix.nixosVmBasedLinuxBuilder = {
    enable = true;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 64 * 1024; # MiB
        };
      };
    };
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
