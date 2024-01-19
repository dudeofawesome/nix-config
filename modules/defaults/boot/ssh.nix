# Enable SSH in initrd. Useful for unlocking LUKS remotely.
# Based on https://mth.st/blog/nixos-initrd-ssh

# Usage:
# Add the following to your per-system conf:
# Network card drivers. Check `lshw` if unsure.
# availableKernelModules = [ "virtio-pci" ];
# networking.interfaces.<interface>.useDHCP = true;

# TODO: would a TPM as an additional factor help protect against MITMing initrd's SSH server?

{ hostname, users, lib, config, ... }: with builtins; {
  config = lib.mkIf
    (
      config ? "disko"
      && config.disko.devices.disk.primary.content.partitions ? "luks"
    )
    {
      sops.secrets."hosts/nixos/${hostname}/initrd_ssh_keyfile_content" = {
        sopsFile = ../../../hosts/nixos/${hostname}/secrets.yaml;
      };

      boot.initrd = {
        # It may be necessary to wait a bit for devices to be initialized.
        # See https://github.com/NixOS/nixpkgs/issues/98741
        preLVMCommands = lib.mkOrder 400 "sleep 1";

        network = {
          enable = true;

          ssh = {
            enable = true;
            # Use something other than 22 since the host private key won't
            #   match the one used post-boot.
            port = 222;
            authorizedKeys = lib.pipe users [
              (mapAttrs (key: val: val.user.openssh.authorizedKeys.keys))
              attrValues
              lib.flatten
            ];
            # Use a unique host private key for pre-boot since its value will be
            #   stored in plaintext in the boot partition, as well as in the nix
            #   store (if using a bootloader that doesn't support initrd secrets).
            hostKeys = [
              # TODO: don't use the host key
              # config.sops.secrets."hosts/nixos/${hostname}/initrd_ssh_keyfile_content".path
              "/etc/ssh/ssh_host_ed25519_key"
            ];
          };

          # Set the shell profile to meet SSH connections with a decryption prompt
          postCommands =
            let
              disk = "/dev/disk/by-partlabel/${config.disko.devices.disk.primary.content.partitions.luks.label}";
            in
            ''
              echo 'network postCommands'
              echo 'cryptsetup-askpass || echo "Unlock was successful; exiting SSH session" && exit 1' >> /root/.profile

              devices="$( \
                ip --oneline link show up \
                  | sed -E 's/^[0-9]+:\s*(\w+):.*$/\1/' \
              )"
              ips="$(ip --oneline addr show "$devices" | head -n1 | sed -E 's/.*\s+inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
              echo "starting sshd at root@$ips:${toString config.boot.initrd.network.ssh.port}..."
            '';
        };

        luks.forceLuksSupportInInitrd = true;

        availableKernelModules = [
          (lib.mkIf (config.boot.kernelPackages ? "aesni_intel") "aesni_intel")
          "cryptd"
          # enable USB storage for devices like a Pi
          "usb_storage"
        ];
      };
    };
}
