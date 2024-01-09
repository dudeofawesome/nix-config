{ config, pkgs, ... }: {
  imports = [
    ../../../modules/defaults/boot/systemd-boot.nix
    # ../../../modules/defaults/wireless.nix
    # ../../../modules/defaults/networkmanager-wireless.nix
    ../../../modules/defaults/nvidia.nix
    ../../../modules/defaults/headful/gaming.nix
    ../../../modules/defaults/headful/fingerprint.nix
  ];

  # sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
  #   sopsFile = ./secrets.yaml;
  #   path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  networking = {
    hostId = "1b29410c"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
