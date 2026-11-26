#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <host> [nix flake check options...]"
  echo
  echo "Evaluate one NixOS or nix-darwin host without building it."
  echo "Reads working-tree files directly, including untracked files."
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

host="${1:-}"
if [[ -z "$host" || "$host" == -* || "$host" == *[!a-zA-Z0-9._-]* ]]; then
  usage >&2
  exit 1
fi
shift

repo_root="$(
  git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel
)"
tmp_dir="$(mktemp -d /tmp/flake-check-host.XXXXXX)"
trap 'rm -rf -- "$tmp_dir"' EXIT

# Reuse the original inputs and lock file; expose only the requested host.
cp "$repo_root/flake.lock" "$tmp_dir/flake.lock"
awk '
  /^  outputs =/ { found = 1; exit }
  { print }
  END { if (!found) exit 1 }
' "$repo_root/flake.nix" > "$tmp_dir/flake.nix"

cat >> "$tmp_dir/flake.nix" <<EOF
  outputs = inputs:
    let
      original = import ((builtins.getEnv "FLAKE_CHECK_REPO_ROOT") + "/flake.nix");
      config = original.outputs inputs;
    in
    if builtins.hasAttr "$host" (config.nixosConfigurations or {}) then {
      nixosConfigurations."$host" = config.nixosConfigurations."$host";
    } else if builtins.hasAttr "$host" (config.darwinConfigurations or {}) then {
      darwinConfigurations."$host" = config.darwinConfigurations."$host";
    } else
      throw "Unknown host: $host";
}
EOF

echo "Checking $host (including untracked source files)..."
# Impure evaluation allows importing the working tree outside the temp flake.
FLAKE_CHECK_REPO_ROOT="$repo_root" nix flake check "path:$tmp_dir" \
  --impure \
  --no-update-lock-file \
  --no-write-lock-file \
  \
  --all-systems \
  --no-build \
  "$@"
