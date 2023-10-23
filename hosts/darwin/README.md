## Initial installation

### Simple

```sh
$ hosts/darwin/first-run.sh
```

### Manual

1. Install Nix

   https://nix.dev/install-nix

1. Install nix-darwin

   https://github.com/LnL7/nix-darwin#step-1-creating-flakenix

1. Install Homebrew

   https://brew.sh

1. Apply flake

   ```sh
   $ darwin-rebuild switch --flake ".#$(hostname)"
   ```
