## Initial installation

### Manual

1. Install NixOS

    https://nixos.org/manual/nixos/stable/#ch-installation

1. Apply flake

    `nh` is not installed yet on a fresh system, so the first apply uses `nixos-rebuild`:

    ```sh
    $ sudo nixos-rebuild switch --flake ".#$hostname"
    ```

    Later applies, once the flake has installed `nh`:

    ```sh
    $ nh os switch ".#$hostname"
    ```
