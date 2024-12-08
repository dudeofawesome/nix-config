{ ... }:
{
  imports = [
    ../../../modules/machine-classes/server.nix
  ];

  networking = {
    hostId = "503a29b9"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  boot.initrd.availableKernelModules = [ "virtio-pci" ];
}
