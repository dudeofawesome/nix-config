# kings-canyon

Louis' home server

## Initial installation

1. Boot up [the NixOS installer ISO]().
1. Follow [the UEFI partitioning instructions here](https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning) up to step 4.
1. Setup LUKS for root.
   1. `sudo cryptsetup luksFormat {YOUR_DEVICE_HERE}`
   1. Make note of the password your chose in the previous step.
   1. `sudo cryptsetup luksOpen {YOUR_DEVICE_HERE} cryptroot`
1. Continue with the NixOS partitioning instructions from the "Formatting" section, making sure to reference the new `/dev/mapper/cryptroot` device instead of the bare dev.
1. Once you've gotten to the step about editing your `configuration.nix`, consider turning on SSH, adding `vim` and `git`, and enabling the nix command and flakes.
1. Ensure that the generated `hardware-configuration.nix` has a definition for `boot.initrd.luks`.

## Applying the config for the 1st time
