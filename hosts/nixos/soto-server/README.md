# soto-server

Josh's home server: family photos, media, Time Machine target. The only place
the photos live, hence the redundancy below.

## Hardware

- System: Dell PowerEdge T430, Xeon E5-2630 v3, 32 GB RAM, two 750 W PSUs
- Boot: Micron 7300 PRO 1.92 TB NVMe (PCIe slot 4)
- Storage: PERC H730 (passthrough disks) with 6× 14 TB WD drives, five bays used
- Out-of-band: iDRAC 8 at 10.0.1.9, serial console on COM2/ttyS1, see [AGENTS.md](AGENTS.md)

## Disks

| Bay | Role                                            |
| --- | ----------------------------------------------- |
| 0–2 | ZFS 3-way mirror `storage` (encrypted)          |
| 3   | cold spare, not in any pool                     |
| 4   | offsite backup disk currently at home (A or B)  |

The NVMe holds the ESP, a 240 GB encrypted bcachefs root and, in the remaining
space, an L2ARC for the pool. Layout and rationale: [disko.nix](disko.nix).

## Boot

The root filesystem asks for its passphrase once in the initrd. Type it on the
console (iDRAC virtual console or `scripts/ipmi.sh soto-server sol activate`),
or `ssh -p 222 root@10.0.1.10` and type it there. The ZFS pool then unlocks
itself from the same secret. The passphrase is in 1Password ("soto-server disk
encryption").

## Backups

- Hourly ZFS snapshots of `storage` (`services.zfs-snapshots`, 48 h / 30 d / 12 m / 2 y).
- Hourly restic backup of the SSD's state (`/var/lib`, `/home`, `/etc/ssh`) into
  `storage/backups/soto-ssd`, taken from read-only bcachefs snapshots:
  [ssd-state-backup.nix](ssd-state-backup.nix).
- Offsite disks `backup-a` / `backup-b`: insert one, wait for
  `journalctl -u 'offsite-backup@*'` to say "complete", pull it. First fill is
  the whole pool; later runs are incremental. Creating a new offsite disk is
  documented in [offsite-backup.nix](offsite-backup.nix).

## Maintenance

- **Replace a failed mirror member**: `zpool replace storage <old-id> /dev/disk/by-id/<new-id>`.
- **Second SSD** (root mirror; the planned one is a 240 GB SATA SSD, 223 GiB):
  partition it as ESP + bcachefs on the rest, then
  `bcachefs device add / /dev/disk/by-id/<new>-part2`, set `replicas = 2` in
  disko.nix and `bcachefs data rereplicate /`. It may be smaller than the NVMe's
  root partition; the smaller device then sets the usable size. Keep the second
  ESP in sync.
- **Samba**: josh's password comes from sops (`samba_password_josh`) and is
  applied at every activation; the Time Machine share is `/storage/timemachine`.

## Initial installation

[`docs/install.md`](./docs/install.md)
