# kings-canyon

Louis' home server

## Hardware

- Motherboard: ASRock Rack ROMED8-2T
- CPU: AMD EPYC 7443 (Milan / EPYC 7003)
- GPU: EVGA FTW3 ULTRA GAMING Nvidia RTX 3080 10GB
- [Full parts list](https://pcpartpicker.com/user/dudeofawesome/saved/cF6wkL)

## Initial installation

Kings-canyon will use native encrypted bcachefs, Secure Boot through Lanzaboote, and Clevis TPM2 unlock in the systemd initrd, following [olympus](../olympus/README.md). Keep a strong recovery passphrase for boots when the TPM policy cannot be satisfied.

Do not use this repository's `nixos-anywhere.sh` wrapper: it expects a LUKS password secret. Format and mount bcachefs before running `nixos-install`.

## Prepare firmware and installer

Enter UEFI Setup with **F2** during POST. Record the BIOS version on the Main screen. Refer to the [ROMED8-2T manual](https://download.asrock.com/Manual/ROMED8-2TBCM.pdf) (printed pages 50, 62, 71–72, and 77); the Secure Boot submenu path below was confirmed on this machine.

| UEFI setting                                                           | Installation value                                                                |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **Boot** → CSM Parameters → CSM                                        | `Disabled`                                                                        |
| **Security** → Secure Boot                                             |                                                                                   |
| ├ Secure Boot                                                          | `Disabled` until signed boot files are installed; then `Enabled`                  |
| ├ Secure Boot Mode                                                     | `Custom`                                                                          |
| ├ Key Management → Factory Key Provision                               | `Disabled`                                                                        |
| ├ Key Management → Platform Key(PK)                                    | `[Delete]`                                                                        |
| **Advanced**                                                           |                                                                                   |
| ├ Chipset Configuration → SPI/LPC TPM Switch                           | Match the installed TPM: `LPC` for TPM1 (17-pin), `SPI` for TPM_BIOS_PH1 (13-pin) |
| ├ AMD CBS → UMC Common Options → DDR4 Common Options → Security → TSME | `Enabled`                                                                         |

### TPM detection

If the installed BIOS exposes **Advanced → Trusted Computing**, set **Security Device Support = Enabled** and verify that it detects a TPM 2.0 device. This conditional menu follows [ASRock's TPM guidance](https://oc.asrock.com/support/faq.asp?id=418); it is not documented in the ROMED8-2T manual. Leave any TPM clear/pending operation unset.

Save with **F10**, then boot the repository's [custom installer](../custom-installer/README.md) in UEFI mode. Clone the repository to `/tmp/nix-config`, then open a root Bash shell with `sudo bash`. The installer command blocks below use Bash syntax and run as root. Check that UEFI and the TPM are available before continuing:

```sh
test -d /sys/firmware/efi
ls -l /dev/tpmrm0
cat /sys/class/tpm/tpm0/tpm_version_major
```

The TPM version must be `2`. If no TPM is detected, resolve the module/interface selection before attempting Clevis enrollment.

## Prepare the host configuration

The host is enabled on nixpkgs-unstable for bcachefs, with the cluster services configured in [default.nix](./default.nix). k3s uses the host package set; compare its evaluated version with haleakala before migration. Before formatting:

1. Verify that the Micron drive configured in [disko.nix](./disko.nix), `/dev/disk/by-id/nvme-Micron_7300_MTFDHBE1T9TDF_20492BD7CB17`, is the intended system drive using `lsblk -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINTS`. Update the path if necessary. The layout includes a 1000M ESP and native encrypted bcachefs using `/tmp/bcachefs-password`.
1. Keep the host-local [clevis.jwe](./clevis.jwe) placeholder until TPM enrollment. Never copy olympus's TPM-bound secret.
1. `system.stateVersion` is `26.05` for this initial installation.
1. Stage the new host files so flake evaluation includes them:

    ```sh
    git add hosts/nixos/kings-canyon
    modprobe bcachefs
    ```

## Partition, encrypt, and mount

The Disko command below destroys all data on the system drive configured in kings-canyon's `disko.nix`. Verify that path before proceeding. Choose a strong recovery passphrase and save it outside this machine as well as in a temporary root-only file in the installer's in-memory `/tmp`:

```sh
read --silent BCACHEFS_PASSPHRASE
printf '%s' "$BCACHEFS_PASSPHRASE" \
  | install -m 600 /dev/stdin /tmp/bcachefs-password
unset BCACHEFS_PASSPHRASE

cd /tmp/nix-config
sudo nix run --inputs-from github:dudeofawesome/nix-config disko -- --mode destroy,format,mount --flake github:dudeofawesome/nix-config#kings-canyon
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
    mount -t bcachefs \
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

Complete the partitioning and mounting steps above first. Create kings-canyon's own Ed25519 SSH host key on the mounted target, preserving it if already present. These commands run in the installer's root Bash shell:

```sh
mountpoint -q /mnt || exit 1
install -d -m 0755 /mnt/etc/ssh
if [ ! -f /mnt/etc/ssh/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -N '' -C kings-canyon \
    -f /mnt/etc/ssh/ssh_host_ed25519_key
fi
nix shell nixpkgs#ssh-to-age --command ssh-to-age \
  -i /mnt/etc/ssh/ssh_host_ed25519_key.pub
```

If preserving a key from a previous installation, restore it into this mounted target before running the commands. Keep the private key on the target; only the public age recipient is needed on the machine that updates SOPS. Add that public recipient to [.sops.yaml](../../../.sops.yaml) as `system_kings-canyon`, and include it in these creation rules:

- Shared `secrets/` files.
- `users/dudeofawesome/secrets.yaml` (login password, Tailscale, Scrutiny, and user services).
- `modules/presets/os/doa-cluster/secrets.yaml` (existing cluster tokens).
- `hosts/nixos/haleakala/secrets.yaml` (the deploy credential reused during migration).

On a machine with an existing decryption identity, run `sops updatekeys --yes` for the affected encrypted files, then bring the updated `.sops.yaml` and re-encrypted secret files into `/tmp/nix-config` on the installer, preserving its local disk and hardware configuration edits. Do this before copying the checkout into `/mnt/etc/nixos` and running `nixos-install`. Keep haleakala's recipient until migration is verified. Do not copy haleakala's SSH host private key to kings-canyon. SOPS access is needed before first boot, including for the configured login password.

## Generate hardware configuration and Secure Boot keys

```sh
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix \
  /tmp/nix-config/hosts/nixos/kings-canyon/hardware-configuration.nix
```

Compare the generated hardware configuration with the EPYC baseline, retaining the appropriate hardware settings. Remove the generated `fileSystems` and `swapDevices` definitions from the copied hardware configuration; Disko owns the filesystem layout. Stage it before evaluating the flake:

```sh
cd /tmp/nix-config
git add hosts/nixos/kings-canyon/hardware-configuration.nix
nix build .#nixosConfigurations.kings-canyon.config.system.build.toplevel \
  --dry-run
```

Create and enroll Secure Boot keys, then copy them into the encrypted root before installing:

```sh
sbctl status
sbctl create-keys
sbctl enroll-keys --microsoft --ignore-immutable
mkdir -p /mnt/var/lib
cp -a /var/lib/sbctl /mnt/var/lib/

mkdir -p /mnt/root
install -m 600 /tmp/bcachefs-password /mnt/root/bcachefs-password
```

`sbctl status` must report Setup Mode before enrollment. Retaining Microsoft certificates supports Microsoft-signed EFI software and option ROMs, following [the Lanzaboote enrollment guidance](https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/enable-secure-boot.md). Keep a secure backup of `/var/lib/sbctl`; its private signing keys must not be committed to Git. The temporary passphrase copy stays inside the encrypted root until TPM enrollment.

## Install and enroll Clevis

Install the prepared local configuration:

```sh
nixos-install --flake github:dudeofawesome/nix-config#kings-canyon
```

Reboot, enable Secure Boot in firmware, and boot kings-canyon. The placeholder JWE cannot unlock the filesystem, so enter the bcachefs recovery passphrase at the first boot. Verify the final boot policy before enrolling Clevis:

```sh
sudo sbctl status
sudo sbctl verify
bootctl status
```

Confirm that Secure Boot is enabled and the installed boot files verify. Re-enter the TSME menu and confirm it remains `Enabled` after saving and rebooting. TSME is transparent to Linux: the absence of an SME activation message in `dmesg` does not imply TSME is disabled, and an `sme` CPU flag alone does not prove it is active.

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
nh os switch github:dudeofawesome/nix-config#kings-canyon
sudo sbctl verify
sudo rm /root/bcachefs-password
```

Build from this local checkout so that the new JWE is included in the initrd. Never commit the plaintext recovery passphrase or reuse olympus's JWE.

Generating the JWE after Secure Boot is enabled binds it to the final PCR-7 Secure Boot policy. PCR 7 does not identify a specific NixOS generation. Reboot again and verify that bcachefs unlocks automatically and the expected services start, keeping console access available during this check.

Firmware, Secure Boot key changes, or TPM replacement/reset can require the recovery passphrase. After a planned policy change, boot with the recovery passphrase, verify Secure Boot, and repeat Clevis enrollment and the rebuild using a temporary root-only passphrase file. Keep the recovery passphrase even after automatic unlock works.

## Migrate haleakala's services

Both the OS hostname and Kubernetes node name are `kings-canyon`. Read-only inspection on 2026-09-09 found haleakala running a single SQLite control plane at `v1.35.6+k3s1`, with all 19 persistent volumes pinned to `kubernetes.io/hostname=haleakala`. Migrating these volume bindings and workload selectors to `kings-canyon` is required before resuming workloads.

The k3s service, Wolf container, and Tang socket wait for `/var/lib/kings-canyon/migration-ready`. Leave this marker absent during installation and restore. Their configuration is enabled, but they will not start automatically before cutover.

### Inventory and backup

Before the outage, confirm the running k3s version still matches the replacement's evaluated `services.k3s.package.version`. Inspect the active datastore again: the presence of an `etcd` directory alone does not imply embedded etcd (haleakala's contained only a historical `name` file). Follow the [K3s backup and restore instructions](https://docs.k3s.io/datastore/backup-restore) for the actual datastore; SQLite needs the database directory and original server token. Use the [K3s upgrade procedure](https://docs.k3s.io/upgrades/manual) separately if versions differ.

Save a private inventory of nodes, workloads, PV/PVC definitions, scheduling selectors, hostPath mounts, USB devices, ingress/load-balancer addresses, and external DNS/router rules. Kubernetes manifests and data migrations are outside this Nix configuration. Capitol-reef was already `NotReady` during inspection; verify its connectivity independently.

Preserve the following state with ownership, permissions, ACLs, and extended attributes:

| State                                                                 | Location / requirement                                                                                                                                                                                           |
| --------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cluster database, token, certificates, manifests, and local-path data | `/var/lib/rancher/k3s`; restore the server state and storage, not transient agent runtime files                                                                                                                  |
| Application volumes                                                   | All referenced `/mnt` paths, plus `/var/lib/rancher/k3s/storage`                                                                                                                                                 |
| Wolf configuration and paired clients                                 | `/var/lib/wolf`; also inventory spawned containers' game/home mounts and Podman volumes                                                                                                                          |
| Tang keys                                                             | Preserve the contents behind `/var/lib/tang` (systemd DynamicUser may place them in `/var/lib/private/tang`), including retired keys; restore into the replacement's state directory with its expected ownership |
| User data                                                             | Required contents of `/home/dudeofawesome` and any additional service bind mounts                                                                                                                                |

The observed `/mnt` volume roots were `atuin`, `home-assistant`, `esphome`, `forgejo`, `forgejo-postgres`, `keycloak`, `matter-server`, `music-assistant`, `ntfy`, `scrutiny-config`, `scrutiny-db`, `teslamate`, `uptime-kuma`, `uptime-kuma-mariadb`, `zigbee2mqtt`, and `zone-configurator`. Discover additional hostPath mounts before the final copy. Move required USB radios/adapters and verify stable device paths and Wolf's RTX 3080 render device on the new machine.

### Cutover

1. Take application-consistent backups and stop workload writers before the final data copy. Stopping k3s alone does not stop all running containers. Stop Wolf sessions and its spawned containers too. Stop haleakala's k3s service and Tang socket, and keep the old host's services stopped across reboots throughout cutover.
1. Make the final offline SQLite/server-state backup and copy the state above onto kings-canyon. Verify that the SOPS server token matches the backed-up cluster token; a new token cannot decrypt the existing bootstrap data. Keep a separate untouched backup for rollback. Let kings-canyon create its own Kubernetes node password; do not restore haleakala's `/etc/rancher/node` or transient agent identity/runtime files onto it.
1. Confirm endpoint handling before enabling the replacement. Capitol-reef currently uses `https://10.0.1.203:6443`. Transfer the old endpoint only after the old host relinquishes it; if using new endpoints, update capitol-reef's `serverAddr`, kubeconfig secrets, API certificate SANs as needed, and external DNS/router/Tang client configuration. Keep each machine's SSH identity distinct. Enroll kings-canyon in Tailscale and verify node addressing and WireGuard connectivity; do not run two copies of a Tailscale identity.
1. Restore Tang's original keys before starting its socket. Validate that existing Clevis clients can unlock against the replacement before retiring the old host.
1. Once restoration and endpoint changes are complete, enable startup on kings-canyon:

    ```sh
    sudo install -d -m 0755 /var/lib/kings-canyon
    sudo touch /var/lib/kings-canyon/migration-ready
    sudo systemctl start k3s.service podman-wolf.service tangd.socket
    ```

1. Confirm the new `kings-canyon` node has registered. Keep application writers stopped while migrating all PV node affinities, workload `nodeSelector`/node affinity/`nodeName` references, and local-path provisioner configuration from `haleakala` to `kings-canyon`. Update the source manifests as well as the restored cluster objects. Verify the copied data paths before rebinding claims. PV node affinity is immutable by default on this Kubernetes version; prepare replacement PVs with `Retain` reclaim policy and explicitly rebind the existing claims while workloads are stopped, following the [Kubernetes volume retention and prebinding guidance](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). Set the old PVs to `Retain` before releasing claims, preserve their data, and do not remove protection finalizers to force deletion. Complete this storage migration before resuming workloads.
1. Verify the API, the `kings-canyon` Kubernetes node's addresses, worker connectivity, all PVCs and workloads, application writes, ingress, DNS, Scrutiny submissions, Wolf pairing/streaming, and Tang unlocks. Reboot kings-canyon and repeat the boot/unlock and service checks.
1. Remove the retired `haleakala` Kubernetes Node object after verifying that no workloads or volumes still depend on it. Retire haleakala's service configuration only after successful verification. This change intentionally leaves its existing configuration available for rollback.

For rollback, stop kings-canyon's migrated services and remove its marker, relinquish transferred endpoints, and restore haleakala's endpoint ownership before starting its services. If the replacement has accepted writes, reconcile or restore the newer application and cluster data before restarting the old copies; the pre-cutover backup alone would lose those writes. Reconcile volume bindings and scheduling selectors back to `haleakala` before resuming workloads there.
