# Enable SSH in initrd for remote LUKS and native bcachefs unlocking.
# Connect with: ssh -p 222 root@<initrd-ip>

# Usage:
# Add the following to your per-system conf:
# Network card drivers. Check `lshw` if unsure.
# availableKernelModules = [ "virtio-pci" ];
# networking.interfaces.<interface>.useDHCP = true;

# TODO: would a TPM as an additional factor help protect against MITMing initrd's SSH server?

{
  hostname,
  users,
  lib,
  config,
  pkgs,
  ...
}:
with builtins;
let
  hasLuks = config ? disko.devices.disk.primary.content.partitions.luks;
  hasEncryptedBcachefs = lib.any (fs: fs.passwordFile != null) (
    attrValues (config.disko.devices.bcachefs_filesystems or { })
  );
in
{
  config = lib.mkIf (config ? "disko" && (hasLuks || hasEncryptedBcachefs)) {
    sops.secrets."hosts/nixos/${hostname}/initrd_ssh_keyfile_content" = lib.mkIf hasLuks {
      sopsFile = ../../../hosts/nixos/${hostname}/secrets.yaml;
    };

    boot.initrd = {
      # Both LUKS and native bcachefs expose systemd password requests,
      # including the fallback when Clevis fails.
      systemd = {
        enable = true;
        users.root.shell = "/bin/unlock-root";
        extraBin.unlock-root = pkgs.writeShellScript "unlock-root" ''
          exec /bin/systemd-tty-ask-password-agent --watch
        '';
      };

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
      };

      luks.forceLuksSupportInInitrd = lib.mkIf hasLuks true;

      availableKernelModules = lib.flatten [
        "cryptd"
        # enable USB storage for devices like a Pi
        "usb_storage"
        (lib.optional (config.boot.kernelPackages ? "aesni_intel") "aesni_intel")
      ];
    };
  };
}
