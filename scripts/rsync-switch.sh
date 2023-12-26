#!/usr/bin/env bash
set -e

hostname="$1"
command="${2:-"switch"}"
path="${3:-"~/git/dudeofawesome/nix-config"}"

ssh "$hostname" -t -C "mkdir -p $path" > /dev/null
rsync --delete --archive ./ "$hostname":"$path"
ssh "$hostname" -t -C 'cd '"$path"' && sudo nixos-rebuild '"$command"' --flake .#'"$hostname"' --show-trace'
