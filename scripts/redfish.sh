#!/usr/bin/env -S NIXPKGS_ALLOW_UNFREE=1 nix
#! nix shell --impure nixpkgs#curl nixpkgs#openssl nixpkgs#jq nixpkgs#_1password-cli --command bash

set -euo pipefail

usage() {
  echo "Usage: $0 [--insecure] <host> <redfish-path> [curl arguments...]"
  echo "Example: $0 soto-server /redfish/v1/Managers/iDRAC.Embedded.1/VirtualMedia/CD"
  echo "         $0 soto-server /redfish/v1/Systems/System.Embedded.1 -X PATCH \\"
  echo "           -d '{\"Boot\":{\"BootSourceOverrideTarget\":\"Cd\",\"BootSourceOverrideEnabled\":\"Once\"}}'"
  echo
  echo "Looks up the host's iDRAC credentials in 1Password using the account and"
  echo "item from its nix config (hardware.bmc.onePassword), then makes a Redfish"
  echo "request. By default the iDRAC's TLS cert is verified against the PEM in"
  echo "the item's 'certificate' field; the cert is CN-only (no SAN), so the"
  echo "request connects by the cert's CN pinned to the item's host address."
  echo "Pass --insecure to skip verification (connect by host, accept any cert)"
  echo "as an escape hatch, e.g. when the iDRAC has regenerated its cert and the"
  echo "1Password copy is stale. Requires the 1Password CLI (op) to be signed in."
}

insecure=false
if [[ "${1:-}" == "--insecure" ]]; then
  insecure=true
  shift
fi

host="${1:-}"
if [[ -z "$host" || "$host" == -* ]]; then
  usage >&2
  exit 1
fi
shift

path="${1:-}"
if [[ -z "$path" || "$path" == -* ]]; then
  echo "A Redfish path is required (e.g. /redfish/v1/Systems/System.Embedded.1)" >&2
  exit 1
fi
shift

if [[ "${1:-}" == "--" ]]; then
  shift
fi

# shellcheck source=lib/bmc.sh
source "$(dirname "${BASH_SOURCE[0]:-$0}")/lib/bmc.sh"
bmc_load "$host"

# The two modes differ only in TLS handling and which hostname the request
# targets; everything else is shared curl arguments.
curl_args=(
  --config -
  --silent --show-error
  --header 'Content-Type: application/json'
)
url_host="$BMC_HOST"

if [[ "$insecure" == true ]]; then
  # Escape hatch: connect straight to the host and accept any cert.
  curl_args+=(--insecure)
else
  # Default: verify against the pinned cert from 1Password.
  idrac_cert="$(bmc_field "$BMC_ITEM_JSON" certificate)"
  if [[ -z "$idrac_cert" ]]; then
    echo "No 'certificate' field in the 1Password item for $host." >&2
    echo "Add the iDRAC's PEM cert to it, or re-run with --insecure." >&2
    exit 1
  fi

  certfile="$(mktemp)"
  trap 'rm -f "$certfile"' EXIT
  printf '%s\n' "$idrac_cert" > "$certfile"

  # The iDRAC cert is CN-only (no SAN), so verify by connecting to its CN and
  # mapping that name to the item's host address.
  cert_cn="$(openssl x509 -in "$certfile" -noout -subject \
    | sed -n 's/.*CN *= *\([^,/]*\).*/\1/p' \
    | sed 's/[[:space:]]*$//')"
  if [[ -z "$cert_cn" ]]; then
    echo "Could not read the CN from the stored certificate." >&2
    exit 1
  fi

  curl_args+=(--cacert "$certfile" --resolve "${cert_cn}:443:${BMC_HOST}")
  url_host="$cert_cn"
fi

# Credentials and URL go through a curl config on stdin so the password never
# appears in the process arguments. Extra arguments ("$@") pass through to curl.
printf 'user = "%s:%s"\nurl = "https://%s%s"\n' \
  "$BMC_USERNAME" "$BMC_PASSWORD" "$url_host" "$path" \
  | curl "${curl_args[@]}" "$@"
