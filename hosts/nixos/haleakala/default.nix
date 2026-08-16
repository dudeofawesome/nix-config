{
  config,
  lib,
  owner,
  ...
}:
{
  imports = [
    ../../../modules/defaults/nvidia.nix
    ../../../modules/defaults/tailscale.nix
    ../../../modules/presets/os/doa-cluster
    ../../../modules/defaults/tang.nix
  ];

  sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
    sopsFile = ./secrets.yaml;
    path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
    owner = owner;
    mode = "0400";
  };

  # Pascal GPUs are only supported by the 580.xx legacy driver.
  hardware = {
    nct6775 = {
      enable = true;
      device = "nct6798";
      channels = builtins.listToAttrs (
        map (channel: {
          name = toString channel;
          value = {
            mode = "smartFanIV";
            stepUpTime = 3000;
            stepDownTime = 15000;
          };
        }) (lib.range 1 4)
      );
    };

    nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  networking = {
    hostId = "1b29410c"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  services.tang.ipAddressAllow = [ "10.0.0.0/20" ];

  services.games-on-whales.wolf = {
    enable = true;
    openFirewall = true;
  };

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      devices = [ { device = "/dev/nvme1n1"; } ];
    };
  };
}
