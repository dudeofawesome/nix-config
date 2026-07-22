#!/usr/bin/env bash
set -euo pipefail

package="${1:?Usage: $0 package}"
result="$(
  UPDATE_SCRIPT_PACKAGE="$package" nix eval --impure --raw --expr '
    let
      flake = builtins.getFlake (toString ./.);
      package = builtins.getEnv "UPDATE_SCRIPT_PACKAGE";
      updateScript = flake.packages.${builtins.currentSystem}.${package}.updateScript;
      drv = builtins.head (builtins.attrNames (builtins.getContext updateScript));
    in
    builtins.concatStringsSep "\n" [ updateScript drv ]
  '
)"
update_script="${result%%$'\n'*}"
drv="${result#*$'\n'}"

nix-store --realise "$drv" >/dev/null
exec "$update_script"
