{ config, pkgs, ... }: {
  imports = [
    ../../../modules/defaults/wireless.nix
  ];

  networking = {
    hostId = "ab94e121"; # head -c 8 /etc/machine-id
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
