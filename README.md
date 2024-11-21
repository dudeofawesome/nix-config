# My Nix Flake

My multi-machine, multi-arch, multi-user, multi-os Nix config

## Attribution

Inspiration & adaptation for flakes from @BriianPowell.

## How to create a new host

1. Decide on the host operating system. Valid options are `nixos` and `darwin`. In this example we'll use nixos, but if you choose another operating system simply replace `nixos` with your operating system in the following steps.
2. Decide on a host name for your machine. In this example we will name our system **starling-vm**.
3. Create a new folder named `starling-vm` under `hosts/nixos/`
4. Create a `hosts/nixos/starling-vm/default.nix`
   1. Copy the contents from an exmalpe machine, and replace `networking.hostId` with your machine's `hostId`
5. SSH into your machine and copy /etc/nixos/hardware-configuration.nix to `hosts/nixos/starling-vm/default.nix`
6. Add your new host to hosts/nixos/default.nix with the appropriate settings
   1. Valid values for `user` are any of ???
   2. Valid values for `owner` are any of the folder names under `users/`
   3. Valid values for `machine-class` are any of the file names under `modules/machine-classes/`
7. Follow instructions in .sops.yaml.
   1. Run `ssh-keyscan 10.211.55.9 2> /dev/null | ssh-to-age 2> /dev/null | sed -nEe 's/(age.+)/\1/mip'`
   2. Add result under new line under systems
   3. Add `- *system_starling-vm` under the first set of creation_rules
   4. Add `- *system_starling-vm` under your user's creation rules under `# Users`
   5. Add a new path_regex under `# Systems`
   6. Run `find . \( -wholename "*/secrets/*.yaml" -o -name "secrets.yaml" \) -type f -exec sops updatekeys --yes {} \;`
8. Run `./scripts/rsync-switch.sh starling-vm=root@10.211.55.9` to apply your new configuration to your machine (replace IP address with your machine's address)

## Set up nixos-anywhere

1. Create a secrets.yaml in your host's folder by running `sops hosts/nixos/starling-vm/secrets.yaml`.
2. Paste the contents below in your sops editor.
3. Replace WHATEVER_PASSWORD_YOU_WANT with a secure password, you will not need to remember this.
4. Replace SSH_KEYFILE with an SSH private key, which you can generate and send to your clipboard by running:
5. Remove all `fileSystems`, `swapDevices`, and `nixpkgs.hostPlatform` configurations from hosts/nixos/starling-vm/hardware-configuration.nix

`ssh-keygen -t ed25519 -f /tmp/nix_temporary_ed25519; cat /tmp/nix_temporary_ed25519 | pbcopy; rm /tmp/nix_temporary_ed25519;`

```
WARNING_unencrypted: |
    DO NOT MODIFY THIS FILE DIRECTLY!
    instead, run this command:
    `sops hosts/nixos/badlands-vm/secrets.yaml`
hosts:
    nixos:
        badlands-vm:
            fde_password: WHATEVER_PASSWORD_YOU_WANT
            initrd_ssh_keyfile_content: |
                SSH_KEYFILE
```

6. Make sure you follow step 7 in the section above if your target machine has a different SSH key
7. Run `./scripts/nixos-anywhere.sh starling-vm nixos-anywhere-demo` replacing nixos-anywhere-demo with your machine's SSH information, e.g. root@10.211.55.11
