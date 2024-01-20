{ pkgs, ... }:
{
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    k6
  ];

  networking.hosts = {
    "192.168.69.5" = [ "badlands-vm" ];
  };

  homebrew.casks = [
    "zoom"
  ];
}
