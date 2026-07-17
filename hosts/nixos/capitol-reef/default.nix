{
  inputs,
  lib,
  ...
}:
{
  imports =
    with inputs.nixos-raspberrypi.nixosModules;
    [
      raspberry-pi-5.base
      # raspberry-pi-5.display-vc4
      # raspberry-pi-5.bluetooth
      trusted-nix-caches
      sd-image
    ]
    ++ [
      ../../../modules/defaults/wireless.nix
      ../../../modules/presets/os/doa-cluster
    ];

  boot = {
    initrd = {
      postMountCommands = ''
        sops_key=/mnt-root/var/lib/sops-nix/key.txt
        firmware_mount=/tmp/capitol-reef-firmware

        if [ ! -e "$sops_key" ] && [ -e /dev/disk/by-label/FIRMWARE ]; then
          mkdir -p "$firmware_mount"
          mount -t vfat -o rw /dev/disk/by-label/FIRMWARE "$firmware_mount"

          if [ -f "$firmware_mount/capitol-reef.agekey" ]; then
            mkdir -p "$(dirname "$sops_key")"
            cp "$firmware_mount/capitol-reef.agekey" "$sops_key"
            chmod 0600 "$sops_key"
            rm "$firmware_mount/capitol-reef.agekey"
          fi

          umount "$firmware_mount"
        fi
      '';
      supportedFilesystems = [ "vfat" ];
    };

    kernelPackages = lib.mkForce (inputs.nixos-raspberrypi.packages.aarch64-linux.linuxPackages_rpi5);
    loader = {
      raspberry-pi.bootloader = "kernel";
      systemd-boot.enable = false;
    };
  };

  services.k3s = {
    role = "agent";
    serverAddr = "https://10.0.1.203:6443";
  };

  sops.age = {
    generateKey = false;
    keyFile = "/var/lib/sops-nix/key.txt";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?
}
