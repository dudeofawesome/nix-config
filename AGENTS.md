## Project Overview

Multi-machine, multi-arch, multi-user, multi-OS Nix flake configuration managing NixOS hosts and macOS (nix-darwin) hosts across x86_64 and aarch64 architectures.

## Common Commands

```sh
# Build a specific host configuration (dry-run to validate)
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel --dry-run
nix build .#darwinConfigurations.<hostname>.config.system.build.toplevel --dry-run

# Apply configuration to local machine
sudo nixos-rebuild switch --flake .#<hostname>    # NixOS
sudo darwin-rebuild switch --flake .#<hostname>         # macOS

# Deploy to remote machine
./scripts/rsync-switch.sh <hostname>[=user@ip]

# Provision a new NixOS machine
./scripts/nixos-anywhere.sh <hostname> root@<ip>
```

## Architecture

### Configuration Flow

`flake.nix` defines all host configurations. Each host is assembled through [hosts/system.nix](hosts/system.nix), which is the OS-agnostic root that composes modules based on parameters: `hostname`, `arch`, `os`, `owner`, `machine-class`, and `users`.

```
flake.nix
  → hosts/{nixos,darwin}/default.nix    # Host registry with per-host parameters
    → hosts/system.nix                  # Assembles modules for a host
      ├── hosts/{nixos,darwin}/<host>/  # Host-specific config + hardware
      ├── modules/machine-classes/      # pc, server, local-vm (with OS suffixes)
      ├── modules/presets/os/base/      # Universal base packages
      ├── modules/defaults/             # Always-applied modules
      ├── users/<owner>/os/             # Owner's OS-level config
      └── modules/host-home-manager.nix # Home Manager integration
        ├── modules/configurable/home-manager/  # Optional HM modules
        └── users/<name>/home-manager/          # Per-user HM config
```

### Module Categories

- **`modules/machine-classes/`** - Machine type definitions (pc, server, local-vm) with OS-specific variants (e.g., `pc.darwin.nix`, `server.linux.nix`)
- **`modules/defaults/`** - Applied to all systems unconditionally. Split into `os/` and `home-manager/` subdirectories
- **`modules/configurable/`** - Optional modules users can enable. Split into `os/` and `home-manager/` subdirectories
- **`modules/presets/`** - Pre-built module combinations (e.g., `base/`, `doa-cluster/`, `paciolan/`)

### Key Patterns

- **Conditional imports**: `doa-lib.try-import` (from [lib/](lib/)) loads a file only if it exists, returning `{}` otherwise. Used extensively for optional OS-specific files like `./module.${os}.nix`
- **Username mapping**: `usersModule.filterMap` in [users/default.nix](users/default.nix) supports renaming users per-host (e.g., `{ dudeofawesome = "lorleans"; }`) while preserving `original_name`
- **Three nixpkgs channels**: `nixpkgs-linux-stable`, `nixpkgs-darwin-stable`, `nixpkgs-unstable`. Modules can selectively use `pkgs-unstable` for specific packages
- **SOPS secrets**: Encrypted with age keys. Per-user keys in `users/<name>/secrets.yaml`, per-host keys in `hosts/<os>/<host>/secrets.yaml`. Key configuration in [.sops.yaml](.sops.yaml)

## Code Style

- Nix files are formatted with `nix fmt`
- Other files use Prettier
- before nix evaluation, newly created files must be staged with git
