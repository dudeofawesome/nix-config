## Initial installation

soto-server uses an encrypted bcachefs root on the NVMe and a natively
encrypted ZFS mirror for data, both unlocked with the `fde_password` secret in
[../secrets.yaml](../secrets.yaml). Installation is done with nixos-anywhere
from any NixOS installer that has SSH; the machine has no local keyboard, so
everything below happens over the iDRAC.

## Boot an installer

The repository's [custom installer](../../custom-installer/README.md) is the
easy path when something can build it. Otherwise the official minimal ISO works
through iDRAC virtual media:

1. Serve the ISO over HTTP with byte-range support (the iDRAC mounts it as a
   block device and reads ranges; a stock `python -m http.server` is refused
   with an internal error). A small range-relaying proxy in front of
   `releases.nixos.org` avoids storing the image anywhere.
2. Attach it: Redfish `VirtualMedia/CD/Actions/VirtualMedia.InsertMedia` with
   the `http://` URL (`scripts/redfish.sh`).
3. Boot from it. On this BIOS the Redfish `BootSourceOverrideTarget=Cd` does not
   select the virtual drive; stage BIOS attributes
   `OneTimeBootMode=OneTimeUefiBootSeq` and
   `OneTimeUefiBootSeqDev=Optical.iDRACVirtual.1-1` via
   `/redfish/v1/Systems/System.Embedded.1/Bios/Settings`, create the config job
   on `/redfish/v1/Managers/iDRAC.Embedded.1/Jobs`, then reset. The job adds one
   extra POST.
4. On the installer's console, run `passwd` for the `nixos` user and note the
   address from `ip -4 a` (10.0.1.10 is the DHCP reservation).

## Stock-ISO gotchas

1. The stock kernel has no bcachefs module (bcachefs is out of tree). On the
   installer:
   ```sh
   out=$(nix-build "<nixpkgs>" -A linuxPackages.bcachefs --no-out-link)
   sudo modprobe lz4_compress lz4hc_compress libpoly1305 libchacha raid6_pq xor
   xz -dc "$out"/lib/modules/*/updates/src/fs/bcachefs/bcachefs.ko.xz > /tmp/bcachefs.ko
   sudo insmod /tmp/bcachefs.ko
   ```
2. disko ([PR 1265](https://github.com/nix-community/disko/pull/1265) unmerged)
   runs `bcachefs unlock` before every subvolume mount, and the second unlock
   fails with "Device or resource busy" once the filesystem is mounted at
   `/mnt`. Finish the remaining mounts by hand with the exact
   `mount -t bcachefs -o X-mount.subdir=@…` lines from the disko log, mount the
   ESP at `/mnt/boot`, run `zfs mount -a`, then rerun the wrapper with
   `--phases install,reboot`.
3. If the disks held a previous pool with the same name, clear its labels first
   (`zpool labelclear -f` on every member, then `wipefs -a`), or disko's
   "import existing pool" step can latch onto it.

## Install

```sh
SSHPASS=<nixos password> ./scripts/nixos-anywhere.sh soto-server nixos@10.0.1.10 --env-password
```

The wrapper decrypts `fde_password` from sops and hands it to disko as the
passphrase for both the bcachefs root and the ZFS pool. `--copy-host-keys`
carries the installer's SSH host key into the installed system, so derive the
host's age key from the installer (`ssh-keyscan 10.0.1.10 | ssh-to-age`), put it
in `.sops.yaml` as `system_soto-server` and re-key the secrets files
(`sops updatekeys`) **before** installing.

## First boot

The initrd asks for the passphrase once: `ssh -p 222 root@10.0.1.10` and type it
(or use the console). Then eject the virtual media (`VirtualMedia.EjectMedia`).
