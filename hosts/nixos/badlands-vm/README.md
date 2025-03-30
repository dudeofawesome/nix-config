# Initial installation

1. Download the minimal ISO for your arch from [NixOS.org](https://nixos.org/download/#nixos-iso)
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
1. Set the ssh login password

    ```sh
    sudo passwd
    ```

1. Show the IP address

    ```sh
    ip a show scope global
    ```

1. Run this repo's [nixos-anywhere](https://nix-community.github.io/nixos-anywhere/) [wrapper script](../../../scripts/nixos-anywhere.sh)

    ```sh
    scripts/nixos-anywhere.sh badlands-vm root@$IP_from_above
    ```

1. When prompted, enter the password you chose earlier

1. Weep as you witness the awesome power of this fully operational battlestation
