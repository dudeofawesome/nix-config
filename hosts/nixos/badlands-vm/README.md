# Initial installation

1. Download minimal ISO from [NixOS.org](https://nixos.org/download/#nixos-iso)
1. Start [UTM](https://getutm.app/)
1. Create the VM

   ```sh
   osascript -e '
       tell application "UTM"
           --- specify a boot ISO
           set iso to POSIX file "'$(echo ~/Downloads/nixos-minimal-*.iso)'"
           --- create an Apple VM for booting Linux
           make new virtual machine with properties {backend:apple, configuration:{name:"NixOS", drives:{{removable:true, source:iso}, {guest size:25600}}, memory:6144}}
       end tell
   '
   ```

1. Update the configuration

   - Virtualization

     | Enable Sound             | ☑︎           |
     | ------------------------ | ------------- |
     | Keyboard                 | Generic USB   |
     | Pointer                  | Generic Mouse |
     | Enable Rosetta           | ☑︎           |
     | Enable Clipboard Sharing | ☑︎           |

   - Add a new Display Device

1. Boot the VM into the NixOS installer
1. Run the following commands in the console

   ```sh
   sudo passwd
   ```

   ```sh
   ip a show scope global
   ```

1. Run this repo's [nixos-anywhere](https://nix-community.github.io/nixos-anywhere/) [wrapper script](../../../scripts/nixos-anywhere.sh)

   ```sh
   scripts/nixos-anywhere.sh badlands-vm root@$IP_from_above
   ```

1. Weep as your new install constantly crashes due to CPU issues(?) 😭
