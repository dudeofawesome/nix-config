# olympus

## Initial installation

Olympus uses native encrypted bcachefs. Clevis unseals the bcachefs recovery
passphrase from TPM2 in the systemd initrd; it is not a LUKS installation.

Do not use this repository's `nixos-anywhere.sh` wrapper for this host. It
expects a LUKS password secret, while Olympus must have bcachefs formatted and
mounted before `nixos-install` runs.

## Prepare firmware and installer

1. Enable TPM 2.0 and put Secure Boot into Setup/Custom mode so that `sbctl` can enroll the new keys. Do not enable Secure Boot until after the first install has produced signed boot files.

    On as Asus motherboard, set OS Type to `Windows UEFI Mode`, Secure Boot Mode to `Custom`, and erase PK in Key Management.

1. Build the repository's [custom installer](../custom-installer/README.md), then boot it in UEFI mode.
1. Clone this repository to `/tmp/nix-config` in the installer.
1. Confirm that bcachefs can load. The custom installer already includes the remaining installation tools.

    ```sh
    sudo modprobe bcachefs
    ```

## Partition, encrypt, and mount

The following command destroys all data on the Olympus system drive, `/dev/disk/by-id/nvme-CT2000P5SSD8_2323413368F7`. Choose a strong recovery passphrase and save it to a temporary root-only file; Disko uses it to encrypt and format bcachefs, and Clevis later seals the same passphrase to the TPM.

```sh
read -rs BCACHEFS_PASSPHRASE
echo
printf '%s' "$BCACHEFS_PASSPHRASE" | sudo install -m 600 /dev/stdin /tmp/bcachefs-password
unset BCACHEFS_PASSPHRASE

# sudo nix run github:nix-community/disko -- --mode disko /tmp/nix-config/hosts/nixos/olympus/disko.nix
sudo nix run github:nix-community/disko -- --mode format --flake github:dudeofawesome/nix-config#olympus
```

Disko creates and mounts the root, `/home`, `/nix`, and `/tmp` bcachefs
subvolumes. The recovery passphrase remains available in the installer's
in-memory `/tmp` for the remaining installation steps.

```sh
sudo -i

keyctl link @u @s
bcachefs unlock -k session /dev/disk/by-partlabel/bcachefs-root \
  < /tmp/bcachefs-password
```

Keep this passphrase somewhere safe. It is the recovery path when TPM/Clevis
cannot unlock the system.

## Generate hardware configuration and Secure Boot keys

Generate the hardware configuration, then copy it into this host directory:

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  /tmp/nix-config/hosts/nixos/olympus/hardware-configuration.nix
```

Remove the generated `fileSystems` and `swapDevices` definitions from the
copied hardware configuration. Olympus already declares its root and ESP
through Disko.

Create and enroll the Secure Boot keys, then copy them into the installed
system before building it:

```sh
sbctl create-keys
sbctl enroll-keys --microsoft
# or possibly maybe need --ignore-immutable

mkdir -p /mnt/var/lib
cp -a /var/lib/sbctl /mnt/var/lib/

# Preserve the passphrase across the reboot inside the encrypted root.
mkdir /mnt/root/
install -m 600 /tmp/bcachefs-password /mnt/root/bcachefs-password
```

Microsoft certificates are retained so that Olympus can boot Windows and
Microsoft-signed third-party EFI software.

## Install and enroll Clevis

Copy the repository contents into the installed system and run the installer:

```sh
mkdir /mnt/etc/
cp -a /tmp/nix-config/. /mnt/etc/nixos/
nixos-install --flake /mnt/etc/nixos#olympus
```

Reboot, enable Secure Boot in firmware, and boot Olympus. The initial
[clevis.jwe](./clevis.jwe) is a placeholder, so the first boot safely falls
back to the bcachefs recovery-passphrase prompt.

Once Olympus has booted with Secure Boot enabled, replace that placeholder
with a TPM-bound JWE and rebuild:

```sh
sudo -i

clevis encrypt tpm2 '{"pcr_ids":"7"}' \
  < /root/bcachefs-password
```

Put the output into `clevis.jwe`

```sh
sudo rm /root/bcachefs-password
nh os switch github:dudeofawesome/nix-config
sbctl verify
```

Generating the JWE only after Secure Boot is active binds it to the final
PCR-7 Secure Boot policy. Subsequent boots unlock bcachefs through Clevis and
fall back to the recovery passphrase if the TPM policy cannot be satisfied.
