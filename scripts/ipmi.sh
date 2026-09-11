#!/usr/bin/env -S nix
#! nix shell nixpkgs#ipmitool --command bash

set -euo pipefail

usage() {
  echo "Usage: $0 <host> [ipmitool arguments...]"
  echo "       $0 --host <host> [ipmitool arguments...]"
  echo "Supported hosts: kings-canyon"
  echo "Example: $0 kings-canyon chassis power status"
  echo "Requires the 1Password CLI (op) to be installed and signed in."
}

case "${1:-}" in
  -h | --help)
    usage
    exit 0
    ;;
  --host)
    host="${2:-}"
    if [[ -z "$host" || "$host" == -* ]]; then
      echo "--host requires a host name" >&2
      exit 1
    fi
    shift 2
    ;;
  --host=*)
    host="${1#--host=}"
    shift
    ;;
  "")
    usage >&2
    exit 1
    ;;
  *)
    host="$1"
    shift
    ;;
esac

case "$host" in
  "kings-canyon")
    op_item_id='trmkkigsfelejx4oftj2am4xqm'
    ;;
  *)
    echo "Unsupported host: $host (supported: kings-canyon)" >&2
    exit 1
    ;;
esac

if [[ "${1:-}" == "--" ]]; then
  shift
fi

# Separate assignments ensure a failed lookup stops the script.
ipmi_host="$(op read "op://Private/$op_item_id/host")"
ipmi_username="$(op read "op://Private/$op_item_id/username")"
IPMI_PASSWORD="$(op read "op://Private/$op_item_id/password")"
if [[ -z "$ipmi_host" || -z "$ipmi_username" || -z "$IPMI_PASSWORD" ]]; then
  echo "The 1Password item must contain a host, username, and password" >&2
  exit 1
fi

# Keep the password out of command-line arguments.
export IPMI_PASSWORD
exec ipmitool \
  -I lanplus \
  -H "$ipmi_host" \
  -U "$ipmi_username" \
  -E \
  "$@"
