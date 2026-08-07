{
  config,
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

  boot.extraModulePackages = [
    # config.boot.kernelPackages.rtl88x2bu # WiFi
  ];

  # Pascal GPUs are only supported by the 580.xx legacy driver.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

  networking = {
    hostId = "1b29410c"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  services.tang.ipAddressAllow = [ "10.0.0.0/20" ];

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      devices = [ { device = "/dev/nvme1n1"; } ];
    };
  };
}
