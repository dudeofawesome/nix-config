{ ... }:
{
  networking.hosts = {
    "192.168.69.5" = [ "badlands-vm" ];
  };

  homebrew.casks = [
    "android-studio"
  ];
}
