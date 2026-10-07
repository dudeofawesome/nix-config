# Shared helper for scripts/ipmi.sh and scripts/redfish.sh.
#
# Resolves a host's baseboard management controller (iDRAC / IPMI) credentials
# from 1Password, using the account and item from its nix config
# (hardware.bmc.onePassword). Source this file, then call `bmc_load <host>`.
#
# On success bmc_load sets these globals:
#   BMC_ITEM_JSON  full `op item get` JSON (for extra fields, e.g. certificate)
#   BMC_HOST       host/address field
#   BMC_USERNAME   username field
#   BMC_PASSWORD   password field
# On any failure it prints to stderr and exits non-zero.
#
# Requires nix, jq, and the 1Password CLI (op) on PATH.

# bmc_field <item-json> <field-label> -> prints the field's value (or nothing).
bmc_field() {
  jq -r --arg label "$2" \
    '(.fields[] | select(.label == $label) | .value) // empty' <<< "$1"
}

bmc_load() {
  local host="$1"
  local repo bmc op_account op_item

  # The 1Password account and item live with the host, in
  # hardware.bmc.onePassword. This file is scripts/lib/bmc.sh, so the repo root
  # is two directories up.
  repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  bmc="$(nix eval --json \
    "${repo}#nixosConfigurations.${host}.config.hardware.bmc.onePassword" \
    2>/dev/null || true)"
  if [[ -z "$bmc" || "$bmc" == "null" ]]; then
    echo "No BMC config for host '$host'." >&2
    echo "Set hardware.bmc.onePassword.{account,item} in hosts/nixos/$host/default.nix." >&2
    exit 1
  fi

  op_account="$(jq -r '.account // empty' <<< "$bmc")"
  op_item="$(jq -r '.item // empty' <<< "$bmc")"
  if [[ -z "$op_account" || -z "$op_item" ]]; then
    echo "hardware.bmc.onePassword for '$host' must set both account and item." >&2
    exit 1
  fi

  # One 1Password fetch; callers pull individual fields with bmc_field.
  BMC_ITEM_JSON="$(op item get "$op_item" --account "$op_account" --reveal --format json)"
  BMC_HOST="$(bmc_field "$BMC_ITEM_JSON" host)"
  BMC_USERNAME="$(bmc_field "$BMC_ITEM_JSON" username)"
  BMC_PASSWORD="$(bmc_field "$BMC_ITEM_JSON" password)"
  if [[ -z "$BMC_HOST" || -z "$BMC_USERNAME" || -z "$BMC_PASSWORD" ]]; then
    echo "The 1Password item must contain host, username, and password fields" >&2
    exit 1
  fi
}
