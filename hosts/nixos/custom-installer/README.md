# NixOS custom installer

## Build images

### USB image

Build a USB image with a writable SSH host-key partition:

```sh
nix build .#nixosConfigurations.custom-installer.config.system.build.usbImage
```

The image is written to `result/usb/custom-installer.img`. Flashing a new image
replaces its SSH host keys.

### ISO image

Build the supported plain ISO for optical media, virtual machines, or a USB
installer with ephemeral SSH host keys:

```sh
nix build .#nixosConfigurations.custom-installer.config.system.build.isoImage
```

## Persistent SSH host keys

The USB image includes an ext4 filesystem labeled `INSTALLER_STATE`. A plain ISO
can use a separately provisioned state filesystem. Creating one manually
destroys the existing contents of the selected partition:

```sh
sudo mkfs.ext4 -L INSTALLER_STATE /dev/disk/by-id/<installer-state-partition>
```

At boot, the installer selects a host key using its primary IPv4 address. The
keys are stored on the state filesystem under `ssh-host-keys/<address>/`. A new
key is created the first time the USB boots at an address, and the previous key
is reused whenever it returns to that address.

Without the state filesystem, SSH uses an ephemeral host key and prints a
warning on the installer console. If SSH does not start, diagnose it with:

```sh
systemctl status custom-installer-ssh-host-key.service
```

After the service starts, display the selected fingerprint with:

```sh
ssh-keygen -lf /run/custom-installer/ssh_host_ed25519_key.pub
```
