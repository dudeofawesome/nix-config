#!/usr/bin/env bash
set -e

hostname="$(echo "$1" | cut -d '=' -f1)"
ssh_conn="$(echo "$1" | cut -d '=' -s -f2)"
ssh_conn="${ssh_conn:-"$hostname"}"
command="${2:-"switch"}"
path="${3:-"~/git/dudeofawesome/nix-config"}"

ssh "$ssh_conn" -t -C "mkdir -p $path" > /dev/null
rsync --delete --archive ./ "$ssh_conn":"$path"
ssh "$ssh_conn" -t -C 'cd '"$path"' && sudo nixos-rebuild '"$command"' --flake .#'"$hostname"' --show-trace'
