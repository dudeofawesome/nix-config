#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

dep_name="${1:-}"

if [[ -z "$dep_name" ]]; then
    echo "usage: $0 <flake-input-name>" >&2
    exit 1
fi

metadata_file="flake.nix"

if ! grep -q "depName=${dep_name}[[:space:]]" "$metadata_file"; then
    echo "unknown flake input: $dep_name" >&2
    exit 1
fi

nix --extra-experimental-features 'nix-command flakes' flake lock --update-input "$dep_name"

new_digest="$(
    perl -0ne '
        my $dep = $ARGV[0];
        if (/"\Q$dep\E"\s*:\s*\{.*?"locked"\s*:\s*\{.*?"rev"\s*:\s*"([^"]+)"/s) {
            print $1;
            exit 0;
        }
        exit 1;
    ' "$dep_name" flake.lock
)"

perl -0pi -e '
    my $dep = $ARGV[0];
    my $digest = $ARGV[1];
    s/^(# renovate-flake: .*?\bdepName=\Q$dep\E\b.*?\bcurrentDigest=)\S+/$1$digest/mg;
' "$dep_name" "$new_digest" "$metadata_file"
