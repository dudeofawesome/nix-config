# Enable SSH in initrd. Useful for unlocking LUKS remotely.
# Based on https://mth.st/blog/nixos-initrd-ssh

# TODO: would a TPM as an additional factor help protect against MITMing initrd's SSH server?

{ users, builtins, ... }: with builtins; {
  boot.initrd = {
    # It may be necessary to wait a bit for devices to be initialized.
    # See https://github.com/NixOS/nixpkgs/issues/98741
    boot.initrd.preLVMCommands = lib.mkBefore 400 "sleep 1";

    network = {
      enable = true;

      ssh = {
        enable = true;
        # Use something other than 22 since the host private key won't match
        #   the one used post-boot.
        port = 222;
        # TODO: do we _really_ want to let _any_ user log in at boot time?
        authorizedKeys = flatten mapAttrs (key: val: val.openssh.authorizedKeys.keys) users;
        # Use a unique host private key for pre-boot since its value will be
        #   stored in plaintext in the boot partition, as well as in the nix
        #   store (if using a bootloader that doesn't support initrd secrets).
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };

      # Set the shell profile to meet SSH connections with a decryption prompt
      #   that writes to /tmp/continue if successful.
      postCommands =
        let
          # I use a LUKS 2 label. Replace this with your disk device's path.
          disk = "/dev/disk/by-label/crypt";
        in
        ''
          echo 'cryptsetup open ${disk} root --type luks && echo > /tmp/continue' >> /root/.profile
          echo 'starting sshd...'
        '';
    };

    # TODO: this option might not exist anymore
    luks.forceLuksSupportInInitrd = true;

    # TODO: this should be defined at the host level, or maybe passed in as args?
    # Network card drivers. Check `lshw` if unsure.
    # kernelModules = [ "smsc95xx" "usbnet" ];

    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # enable USB storage for devices like a Pi
      "usb_storage"
    ];

    # Block the boot process until /tmp/continue is written to.
    postDeviceCommands = ''
      echo 'waiting for root device to be opened...'
      mkfifo /tmp/continue
      cat /tmp/continue
    '';
  };
}
