{ pkgs, ... }:
{
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    k6
    zoom-us
  ];

  networking.hosts = {
    "192.168.69.5" = [ "badlands-vm" ];
  };

  homebrew.casks = [
    "android-studio"
  ];
}
