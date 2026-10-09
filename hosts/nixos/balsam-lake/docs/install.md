## Initial installation

balsam-lake will use native encrypted bcachefs, Secure Boot through Lanzaboote, and Clevis TPM2 unlock in the systemd initrd.

## Prepare firmware and installer

Enter UEFI Setup with **F10** during POST.

| UEFI setting                       | Installation value                                               |
| ---------------------------------- | ---------------------------------------------------------------- |
| **Security**                       |                                                                  |
| ├ Memory Security                  | `Enabled` (verify)                                               |
| ├ **System Security**              |                                                                  |
| ├─ Virtualization Technology (VTx) | `Enabled`                                                        |
| ├ **Secure Boot Configuration**    |                                                                  |
| ├─ Secure Boot                     | `Disabled` until signed boot files are installed; then `Enabled` |
| ├─ Clear Secure Boot Keys          | `Clear` (for setup)                                              |
| ├─ Key Ownership                   | `Custom keys`                                                    |
| ├─ Fast Boot                       | `Disabled`                                                       |
| **Advanced**                       |                                                                  |
| ├ **Power-On Options**             |                                                                  |
| ├─ POST Messages                   | `Enabled`                                                        |
| ├─ After Power Loss                | `Previous State`                                                 |
| ├ **Device Options**               |                                                                  |
| ├─ Num Lock State at Power-On      | `On`                                                             |

Save and apply changes, then boot the repository's [custom installer](../custom-installer/README.md) in UEFI mode. Check that UEFI, TPM, and bcachefs are available before continuing:

```sh
test -d /sys/firmware/efi
ls -l /dev/tpmrm0
cat /sys/class/tpm/tpm0/tpm_version_major
modprobe bcachefs
```

The TPM version must be `2`. If no TPM is detected, resolve the module/interface selection before attempting Clevis enrollment.

## Partition, encrypt, and mount

The Disko command below destroys all data on the system drive configured in `disko.nix`. Verify that path before proceeding. Choose a strong recovery passphrase and save it outside this machine as well as in a temporary root-only file in the installer's in-memory `/tmp`:

```sh
read --silent BCACHEFS_PASSPHRASE
printf '%s' "$BCACHEFS_PASSPHRASE" \
  | install -m 600 /dev/stdin /tmp/bcachefs-password
unset BCACHEFS_PASSPHRASE

sudo nix run --inputs-from github:dudeofawesome/nix-config disko -- --mode destroy,format,mount --flake github:dudeofawesome/nix-config#balsam-lake
```

Disko encrypts bcachefs and mounts root, `/home`, `/nix`, `/tmp`, and the ESP. Keep any swap inside encrypted storage. Verify all target mounts before continuing:

```sh
findmnt -R /mnt
```

### Recover from a repeated-unlock failure

Disko 1.13.0 can fail with `Device or resource busy` when it tries to unlock the same encrypted filesystem for `/home` after already mounting root. If the log shows successful formatting, subvolume creation, and mounting of `/mnt` and `/mnt/boot`, finish mounting the remaining subvolumes without unlocking again. Do not rerun `destroy,format,mount` for this failure.

First check `findmnt -R /mnt`: `/mnt` must be the bcachefs root subvolume and `/mnt/boot` must be the FAT ESP. For the missing mounts, run these commands in the installer's root Bash shell:

```sh
for subvol in home nix tmp; do
  if ! mountpoint -q "/mnt/$subvol"; then
    sudo mount -t bcachefs \
      -o "X-mount.mkdir,X-mount.subdir=@$subvol,noatime" \
      /dev/disk/by-uuid/4813494d-137e-1631-bba3-01d5acab6e7b \
      "/mnt/$subvol"
  fi
done
findmnt -R /mnt
```

The format command already sets the filesystem's default compression to zstd. These recovery mounts omit compression options because the installer reports that they are no longer accepted at mount time. The shared Disko configuration's per-subvolume compression options still need migration to the supported runtime/per-directory settings.

Do not run `bcachefs unlock` again while this filesystem is mounted. If unlocking is needed after all its mounts have been removed, use the actual GPT partition path `/dev/disk/by-partlabel/disk-primary-root` (or the Micron drive's stable partition by-id path), not `/dev/disk/by-partlabel/root`.

## Enroll SOPS on the mounted target

Follow the instructions in [.sops.yaml](../../../.sops.yaml), and include it in these creation rules:

- Shared `secrets/` files.
- `secrets.yaml` (login password, Tailscale, Scrutiny, and user services).
- `users/dudeofawesome/secrets.yaml` (login password, Tailscale, Scrutiny, and user services).
- `modules/presets/os/doa-cluster/secrets.yaml` (existing cluster tokens).
- `hosts/nixos/balsam-lake/secrets.yaml` (the deploy credential reused during migration).

On a machine with an existing decryption identity, run `sops updatekeys --yes` for the affected encrypted files.

## Generate hardware configuration and Secure Boot keys

```sh
nixos-generate-config --root /mnt
cat /mnt/etc/nixos/hardware-configuration.nix
```

Compare the generated hardware configuration with the baseline, retaining the appropriate hardware settings. Remove the generated `fileSystems` and `swapDevices` definitions from the copied hardware configuration; Disko owns the filesystem layout. Stage it before evaluating the flake:

```sh
git add hosts/nixos/balsam-lake/hardware-configuration.nix
nix build .#nixosConfigurations.balsam-lake.config.system.build.toplevel \
  --dry-run
```

Create and enroll Secure Boot keys, then copy them into the encrypted root before installing:

```sh
sbctl status
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft --ignore-immutable
sudo mkdir -p /mnt/var/lib
sudo cp -a /var/lib/sbctl /mnt/var/lib/

sudo mkdir -p /mnt/root
sudo install -m 600 /tmp/bcachefs-password /mnt/root/bcachefs-password
```

`sbctl status` must report Setup Mode before enrollment. Retaining Microsoft certificates supports Microsoft-signed EFI software and option ROMs, following [the Lanzaboote enrollment guidance](https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/enable-secure-boot.md). Keep a secure backup of `/var/lib/sbctl`; its private signing keys must not be committed to Git. The temporary passphrase copy stays inside the encrypted root until TPM enrollment.

## Install, enroll Clevis

Setup remote builder

```sh
sudo -i
mkdir -p /root/.ssh
chmod 700 /root/.ssh
ssh-keygen -t ed25519 -N '' -f /root/.ssh/kings-builder
cat /root/.ssh/kings-builder.pub
```

Add that key to kings-canyon's `authorized_keys`, and test the connection

```sh
ssh -i /root/.ssh/kings-builder dudeofawesome@kings-canyon nix --version
```

Install the configuration:

```sh
nixos-install \
  --flake github:dudeofawesome/nix-config#balsam-lake \
  --max-jobs 0 \
  --option builders \
    'ssh-ng://dudeofawesome@kings-canyon x86_64-linux /root/.ssh/kings-builder 2 1 benchmark,big-parallel,kvm,nixos-test' \
  --option builders-use-substitutes true
```

Reboot, enable Secure Boot in firmware, and boot balsam-lake. Enter the bcachefs recovery passphrase at the first boot. Verify the final boot policy before enrolling Clevis:

```sh
sudo sbctl status
sudo sbctl verify
bootctl status
```

Confirm that Secure Boot is enabled and the installed boot files verify.

Once booted with Secure Boot enabled, seal the recovery passphrase to this machine's TPM and replace the placeholder JWE:

```sh
cd /etc/nixos
sudo clevis encrypt tpm2 '{"pcr_ids":"7"}' \
  < /root/bcachefs-password
mkdir -p ~/.config/sops/age
sudo nix shell nixpkgs#ssh-to-age --command ssh-to-age \
  -i /etc/ssh/ssh_host_ed25519_key --private-key > ~/.config/sops/age/keys.txt
```

commit to `clevis.jwe` and push

```sh
nh os switch github:dudeofawesome/nix-config
sudo sbctl verify
sudo rm /root/bcachefs-password
```

Generating the JWE after Secure Boot is enabled binds it to the final PCR-7 Secure Boot policy. PCR 7 does not identify a specific NixOS generation. Reboot again and verify that bcachefs unlocks automatically and the expected services start, keeping console access available during this check.

Firmware, Secure Boot key changes, or TPM replacement/reset can require the recovery passphrase. After a planned policy change, boot with the recovery passphrase, verify Secure Boot, and repeat Clevis enrollment and the rebuild using a temporary root-only passphrase file. Keep the recovery passphrase even after automatic unlock works.
