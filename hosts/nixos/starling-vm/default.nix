{ config, pkgs, ... }: {
  imports = [ ];

  networking = {
    hostId = "5b05992f"; # head -c 8 /etc/machine-id
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
