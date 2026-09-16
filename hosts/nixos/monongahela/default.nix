{ lib, config, ... }:
{
  imports = [
    ../../../modules/defaults/tailscale.nix
  ];

  sops.secrets."hosts/nixos/monongahela/ssh-keys/dudeofawesome_nix-config/private" = {
    sopsFile = ./secrets.yaml;
    path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  };

  networking = {
    hostId = "ab94e121"; # head -c 8 /etc/machine-id
    firewall.enable = false;
    networkmanager.enable = true;
  };

  security.tpm2.enable = true;

  # services.scrutiny.collector = {
  #   enable = true;
  #   # user = "root";
  #   # group = "root";
  #   settings = {
  #     version = 1;
  #     api.endpoint = "http://scrutiny.scrutiny.svc.cluster.local";
  #     host.id = config.networking.hostName;
  #     devices = [
  #       {
  #         device = "/dev/sda";
  #         type = "sat";
  #       }
  #     ];
  #   };
  # };
}
