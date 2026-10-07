#!/usr/bin/env -S NIXPKGS_ALLOW_UNFREE=1 nix
#! nix shell --impure nixpkgs#ipmitool nixpkgs#jq nixpkgs#_1password-cli --command bash

set -euo pipefail

usage() {
  echo "Usage: $0 <host> [ipmitool arguments...]"
  echo "Example: $0 soto-server chassis power status"
  echo
  echo "Looks up the host's BMC/IPMI credentials in 1Password using the account"
  echo "and item from its nix config (hardware.bmc.onePassword), then runs"
  echo "ipmitool against it. Requires the 1Password CLI (op) to be signed in."
}

host="${1:-}"
if [[ -z "$host" || "$host" == -* ]]; then
  usage >&2
  exit 1
fi
shift

if [[ "${1:-}" == "--" ]]; then
  shift
fi

# shellcheck source=lib/bmc.sh
source "$(dirname "${BASH_SOURCE[0]:-$0}")/lib/bmc.sh"
bmc_load "$host"

# Keep the password out of the process arguments.
export IPMI_PASSWORD="$BMC_PASSWORD"
exec ipmitool \
  -I lanplus \
  -H "$BMC_HOST" \
  -U "$BMC_USERNAME" \
  -E \
  "$@"
