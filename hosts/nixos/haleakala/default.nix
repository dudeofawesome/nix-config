{ hostname, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
    ../../../modules/boot/systemd-boot.nix
    # ../../../modules/wireless.nix
    # ../../../modules/networkmanager-wireless.nix
    ../../../modules/nvidia.nix
    ../../../modules/roles/gaming.nix
    ../../../modules/fingerprint.nix
  ];

  # sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
  #   sopsFile = ./secrets.yaml;
  #   path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  networking = {
    hostName = hostname;
    hostId = "1b29410c"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
