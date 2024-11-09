#!/usr/bin/env bash
set -e

flake="$1"
ssh_conn="$2"

# TODO: get the path from the config
fde_password_file="/run/secrets/hosts/nixos/$flake/fde_password"
fde_password_dir="$(dirname "$fde_password_file")"

sudo mkdir -p "$fde_password_dir"
sudo chown "$USER" "$fde_password_dir"
sops \
  --decrypt \
  --extract '["hosts"]["nixos"]["'"$flake"'"]["fde_password"]' \
  --output "$fde_password_file" \
  "hosts/nixos/$flake/secrets.yaml"

# nix run github:nix-community/nixos-anywhere -- \
nix run github:dudeofawesome/nixos-anywhere/fix/create-encryption-keys-dir -- \
  --flake .#"$flake" \
  --build-on-remote \
  --copy-host-keys \
  --disk-encryption-keys \
    `# remote path` \
    "$fde_password_file" \
    `# local path` \
    "$fde_password_file" \
  --debug \
  "$ssh_conn"
