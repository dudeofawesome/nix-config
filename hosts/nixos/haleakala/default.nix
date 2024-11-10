{ config, pkgs, ... }: {
  imports = [
    ../../../modules/defaults/wireless.nix
    ../../../modules/defaults/nvidia.nix
    ../../../modules/defaults/headful/gaming.nix
    ../../../modules/defaults/headful/fingerprint.nix
  ];

  # sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
  #   sopsFile = ./secrets.yaml;
  #   path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  boot.extraModulePackages = [ config.boot.kernelPackages.rtl88x2bu ];

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
