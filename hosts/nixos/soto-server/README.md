# soto-server runbook

Layout and rationale are in [disko.nix](disko.nix). Out-of-band access is in [AGENTS.md](AGENTS.md).

## Install / reinstall

Boot the machine into any NixOS installer with SSH (the official minimal ISO via
iDRAC virtual media works; set a password for `nixos` on the console), then:

```sh
./scripts/nixos-anywhere.sh soto-server nixos@10.0.1.10
```

The script decrypts `fde_password` from [secrets.yaml](secrets.yaml) and hands it
to disko; the same passphrase encrypts the bcachefs root and the ZFS `storage` pool.
The passphrase is in 1Password ("soto-server disk encryption").

Two gotchas when installing from the **stock** NixOS ISO (the custom installer
in `hosts/nixos/custom-installer` avoids the first):

1. Its kernel has no bcachefs module (bcachefs is out of tree). Before running
   nixos-anywhere, on the installer:
   ```sh
   out=$(nix-build "<nixpkgs>" -A linuxPackages.bcachefs --no-out-link)
   sudo modprobe lz4_compress lz4hc_compress libpoly1305 libchacha raid6_pq xor
   xz -dc "$out"/lib/modules/*/updates/src/fs/bcachefs/bcachefs.ko.xz > /tmp/bcachefs.ko
   sudo insmod /tmp/bcachefs.ko
   ```
2. disko (as of early 2026, [PR 1265](https://github.com/nix-community/disko/pull/1265)
   unmerged) runs `bcachefs unlock` before every subvolume mount, and the second
   unlock fails with "Device or resource busy" once the filesystem is mounted at
   `/mnt`. Finish the remaining mounts by hand with the exact `mount -t bcachefs
   -o X-mount.subdir=@…` lines from the disko log, mount the ESP at `/mnt/boot`,
   run `zfs mount -a`, then rerun the wrapper with `--phases install,reboot`.

## Boot

The root filesystem asks for its passphrase in the initrd. Either type it on the
console (iDRAC virtual console or `scripts/ipmi.sh soto-server sol activate`) or
`ssh -p 222 root@10.0.1.10` and type it there. The ZFS pool unlocks itself
afterwards from the same secret.

## Drives

| Bay | Role                                   |
| --- | -------------------------------------- |
| 0-2 | `storage` 3-way mirror                 |
| 3   | cold spare (not in any pool)           |
| 4   | offsite disk currently at home (A or B) |

- **Replace a failed mirror member**: `zpool replace storage <old-id> /dev/disk/by-id/<new-id>`.
- **Offsite rotation**: insert the disk, wait for `journalctl -u 'offsite-backup@*'` to say
  "complete", pull it. First fill is the whole pool; later runs are incremental.
  Creating a new offsite disk is documented in [offsite-backup.nix](offsite-backup.nix).
- **Second SSD** (root mirror): partition it like the NVMe (ESP + bcachefs), then
  `bcachefs device add / /dev/disk/by-id/<new>-part2`, set `replicas = 2` in
  disko.nix and `bcachefs data rereplicate /`. Keep the second ESP in sync.

## Backups of the SSD itself

`ssd-state-backup.timer` copies `/var/lib`, `/home` and `/etc/ssh` hourly into
`/storage/backups/soto-ssd` (see [ssd-state-backup.nix](ssd-state-backup.nix)).
Add a database dump there when a database exists.
