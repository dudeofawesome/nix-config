#!/usr/bin/env nix
#! nix shell nixpkgs#bash github:nix-community/nix4vscode --command bash
set -e

output="extensions.nix"

nix4vscode extensions.toml --output "$output"
nix fmt "$output"

sed -i '1i# Do not modify this file!  It was generated by `update-extensions.sh` \
# and may be overwritten by future invocations.  Please make changes \
# to extensions.toml instead. \
' "$output"

echo "Updated extensions"
