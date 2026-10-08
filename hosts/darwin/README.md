## Initial installation

### Simple

```sh
$ curl -sSL https://nix-darwin-setup.orleans.io | bash
```

### Manual

1. Install Nix

    https://nix.dev/install-nix

1. Install nix-darwin

    https://github.com/LnL7/nix-darwin#step-1-creating-flakenix

1. Install Homebrew

    https://brew.sh

1. Apply flake

    `nh` is not installed yet on a fresh system, so the first apply uses `darwin-rebuild`:

    ```sh
    $ darwin-rebuild switch --flake ".#$hostname"
    ```

    Later applies, once the flake has installed `nh`:

    ```sh
    $ nh darwin switch ".#$hostname"
    ```
