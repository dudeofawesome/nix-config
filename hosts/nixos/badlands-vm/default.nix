{ hostname, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../configuration.nix
    ../../../modules/boot/systemd-boot.nix
    ../../../modules/fs/zfs.nix
    ../../../modules/time-machine-server.nix
    ../../../modules/samba-users.nix
  ];

  networking = {
    hostName = hostname;
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
