{ config, pkgs, ... }: {
  imports = [
    ../../../modules/machine-classes/local-vm.nix
    ../../../modules/defaults/wireless.nix
    # ../../../modules/defaults/nvidia.nix
    # ../../../modules/defaults/headful/gaming.nix
    # ../../../modules/defaults/headful/fingerprint.nix
  ];

  # sops.secrets."hosts/nixos/haleakala/ssh-keys/dudeofawesome_nix-config/private" = {
  #   sopsFile = ./secrets.yaml;
  #   path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  networking = {
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };
}
