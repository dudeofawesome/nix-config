#!/usr/bin/env nix
#! nix shell nixpkgs#bash nixpkgs#sops github:nix-community/nixos-anywhere/1.8.0 --command bash
set -e

# This script will run nixos-anywhere targeting the specified machine with the
# sops encryption keys already set up for your host. To use this script for a
# host named soto-server at 10.0.1.10, run:
#   nixos-anywhere.sh soto-server root@10.0.1.10

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: $0 <host> <ssh-destination>" 1>&2
  echo "  eg: $0 badlands-vm root@10.0.0.100" 1>&2
  exit 0
fi

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

nixos-anywhere -- \
  --flake .#"$flake" \
  --build-on remote \
  --copy-host-keys \
  --disk-encryption-keys \
    `# remote path` \
    "$fde_password_file" \
    `# local path` \
    "$fde_password_file" \
  --debug \
  "$ssh_conn"


# TODO: clean up decrypted password files
# Function to cleanup temporary directory on exit
# cleanup() {
#   rm -rf "$temp"
# }
# trap cleanup EXIT
