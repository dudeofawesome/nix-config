{ config, pkgs, ... }: {
  imports = [
    ../../../modules/boot/systemd-boot.nix
    ../../../modules/wireless.nix
  ];

  networking = {
    hostName = "monongahela";
    hostId = "ab94e121"; # head -c 8 /etc/machine-id
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
