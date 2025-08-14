{ config, os, ... }:
{
  imports = [
    ../../../modules/defaults/nvidia.nix
    ../../../modules/defaults/tailscale.nix
    ../../../modules/presets/os/doa-cluster
  ];

  # sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
  #   sopsFile = ./secrets.yaml;
  #   path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  boot.extraModulePackages = [
    # config.boot.kernelPackages.rtl88x2bu # WiFi
  ];

  networking = {
    hostId = "1b29410c"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  programs = {
    gnome = {
      # autoLoginEnable = true;
    };
  };
}
