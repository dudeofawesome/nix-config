# capitol-reef

Raspberry Pi 5 k3s agent for the `doa-cluster` cluster. The host boots from a
microSD card, joins the cluster through Haleakala's LAN address, and supports
both Ethernet and the SOPS-managed NetworkManager Wi-Fi profiles.

## Prepare the SOPS identity

The public recipient is recorded in `.sops.yaml`, and the required secret files
are encrypted for it. The private identity is generated locally at the path
below, intentionally ignored by Git, and must not be added to the Nix store.
Back it up in the password manager before building from another machine or
flashing the microSD card.

```sh
hosts/nixos/capitol-reef/capitol-reef.agekey
```

Do not regenerate the identity without also replacing `system_capitol-reef` in
`.sops.yaml` and updating the affected SOPS files' recipients.

## Build the image

The image is an `aarch64-linux` derivation:

```sh
nix --accept-flake-config build \
  .#nixosConfigurations.capitol-reef.config.system.build.sdImage
```

On x86_64 NixOS, first enable AArch64 emulation on the builder:

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

On arm64 macOS, enable nix-darwin's Linux builder or use another configured
`aarch64-linux` remote builder:

```nix
nix.linux-builder.enable = true;
```

The compressed image is written under `result/sd-image/`.

## Flash and provision

Flash the `.img.zst` file to the microSD card with a trusted imaging tool or
`zstd` and `dd`. Double-check the destination device before writing it.

```sh
nix shell nixpkgs#zstd --command zstd -dc \
  result/sd-image/nixos-image-rpi5-kernel.img.zst |
  sudo dd of=/dev/DISKNUMBER bs=4m
```

After flashing, mount the FAT partition labeled `FIRMWARE` and copy the private
identity to its root:

```sh
cp hosts/nixos/capitol-reef/capitol-reef.agekey /Volumes/FIRMWARE/
```

On first boot, the initrd moves the identity to
`/var/lib/sops-nix/key.txt`, sets mode `0600`, and removes the FAT-partition
copy before SOPS secrets are installed. The root filesystem expands to fill the
microSD card automatically.

Once booted, verify the node from an existing cluster admin:

```sh
kubectl get node capitol-reef -o wide
```

## Subsequent updates

```sh
nh os switch .#capitol-reef --target-host 10.0.16.238
```
