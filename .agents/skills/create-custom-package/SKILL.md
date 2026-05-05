---
name: create-custom-package
description: "Create a new repo-local custom Nix package under packages/, following this flake's package patterns and validation flow."
when_to_use: 'Use when the user asks to add a new custom package, write a new package.nix, package an upstream tool/app for this repo'
allowed-tools:
    - Bash(nix build *)
    - Bash(nix fmt *)
---

# Create Custom Package

Add new packages in `packages/<name>/package.nix`.

`packages/default.nix` auto-imports every subdirectory containing `package.nix`, and `flake.nix` exposes them as `packages.<system>.<name>`. Do not add manual registry entries for normal package creation.

## Workflow

1. Inspect nearby examples in `packages/` before choosing a builder.
2. Create `packages/<name>/package.nix`.
3. Pick the simplest matching pattern:
    - `buildGoModule` for Go projects with modules
    - `buildNpmPackage` for Node packages
    - `stdenv.mkDerivation` for simple binaries, app bundles, or custom installs
    - another language-specific builder only when the upstream project clearly needs it
4. Add `mainProgram` for CLI tools when there is one clear executable.
5. Restrict `platforms` when the package is OS-specific, like `lib.platforms.darwin`.

## Hashes And Build Inputs

- Use `fetchFromGitHub` when the source is a GitHub repo; otherwise choose the narrowest fetcher that fits.
- For package hashes use `lib.fakeHash`, build once (expecting a failure), and replace it with the reported value.

## Validation

Prefer this validation sequence:

```sh
nix fmt
nix build .#<package-name> --dry-run
nix build .#<package-name>
```
