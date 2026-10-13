# Initial Install

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

Crater-lake and capitol-reef are configured to send Linux builds to kings-canyon, which provides native `x86_64-linux` builds and QEMU-emulated `aarch64-linux` builds. Apply kings-canyon's configuration before activating either client. ARM64 emulation is slower than native execution and does not support ARM64 KVM builds. Darwin ARM64 builds still require a macOS builder.

Both clients authenticate using their root-readable `/etc/ssh/ssh_host_ed25519_key`; their public keys are authorized in kings-canyon's restricted `nix-ssh` account. The shared builder definition pins kings-canyon's host key. Update these entries if a host key is rotated.

Capitol-reef sets `nix.settings.max-jobs = 0` to offload all compilation. Kings-canyon must be reachable for uncached builds. To allow a local recovery build, pass `--option builders '' --max-jobs 1` to `nix build`.

After activating the configurations, test ARM64 remote execution from either client:

```sh
nix build --impure --no-link --max-jobs 0 --expr '
  let
    flake = builtins.getFlake (toString ./.);
    pkgs = import flake.inputs.nixpkgs-linux-stable {
      system = "aarch64-linux";
    };
  in pkgs.runCommand "remote-arm64-smoke-test" {
    preferLocalBuild = false;
    allowSubstitutes = false;
  } "uname -m > $out"
'
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

Home Manager also needs the existing `user_dudeofawesome` private age identity at `/home/dudeofawesome/.config/sops/age/keys.txt`, owned by `dudeofawesome` with mode `0600` (parent directory `0700`). Restore that identity from its secure backup before switching. The system identity at `/var/lib/sops-nix/key.txt` only provisions system-level secrets; it does not populate the Home Manager key file. Generating a new user key without updating the encrypted files' recipients will not work.

The firewall uses `pkgs.iptables` with its nftables compatibility backend, matching the k3s package. This works with the Pi kernel's nftables support without enabling legacy xtables or rebuilding the kernel. The firewall still uses iptables-style rules; native nftables firewall and kube-proxy modes are separate migrations.

```sh
nh os switch .#capitol-reef --target-host 10.0.16.238
```

After switching, verify `systemctl status firewall home-manager-dudeofawesome`, `systemctl --user status sops-nix`, and `iptables --version` (which should report `nf_tables`).
