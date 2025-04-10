#!/usr/bin/env bash
set -e

# This script applies the specified flake to the target machine. Example:
#   rsync-switch.sh soto-server
#   rsync-switch.sh soto-server=nixos@10.0.1.10

if [ "$1" == "--help" ]; then
  echo -e ""
  echo -e "Usage:\t$0 hostname[=ssh_connection] [nix_command] [path]"
  echo -e ""
  echo -e "Uploads this flake to a target and switches to the new configuration."
  exit 0
fi

hostname="$(echo "$1" | cut -d '=' -f1)"
ssh_conn="$(echo "$1" | cut -d '=' -s -f2)"
ssh_conn="${ssh_conn:-"$hostname"}"

if [ -z "$hostname" ]; then
  >&2 echo "hostname must be set."
  exit 1
fi

path="${3:-"~/git/dudeofawesome/nix-config"}"

ssh "$ssh_conn" -q "mkdir -p $path" > /dev/null
rsync --delete --archive ./ "$ssh_conn":"$path"

base_command=""
target_os="$(ssh "$ssh_conn" -q 'uname' | xargs echo -n)"
case "$target_os" in
  'Linux')
    base_command="sudo nixos-rebuild";;
  'Darwin')
    base_command="darwin-rebuild";;
  *)
    >&2 echo -e "Unsupported OS: '$target_os'"
    exit 1
    ;;
esac
command="${2:-"switch"}"
ssh "$ssh_conn" -t "$base_command"' '"$command"' --flake '"$path"'#'"$hostname"' --show-trace'
