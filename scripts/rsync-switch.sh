#!/usr/bin/env bash
set -e

hostname="$1"
path="${2:-"~/git/dudeofawesome/nix-config"}"

ssh "$hostname" -t -C "mkdir -p $path" > /dev/null
rsync --delete --archive ./ "$hostname":"$path"
ssh "$hostname" -t -C 'cd '"$path"' && sudo nixos-rebuild switch --flake .#'"$hostname"' --show-trace'
