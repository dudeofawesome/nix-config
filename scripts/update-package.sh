#!/usr/bin/env bash
set -euo pipefail

package="${1:?Usage: $0 package}"
data="$(
  UPDATE_SCRIPT_PACKAGE="$package" nix eval --impure --json --expr '
    let
      flake = builtins.getFlake (toString ./.);
      requestedAttrPath = builtins.getEnv "UPDATE_SCRIPT_PACKAGE";
      package = flake.packages.${builtins.currentSystem}.${requestedAttrPath};
      update = package.updateScript;
      rawCommand = if builtins.isAttrs update && update ? command then update.command else update;
      baseCommand = if builtins.isList rawCommand then rawCommand else [ rawCommand ];
      commandStrings = map toString baseCommand;
      isNixUpdate = builtins.baseNameOf (builtins.head commandStrings) == "nix-update";
      hasFlakeFlag = builtins.elem "--flake" commandStrings || builtins.elem "-F" commandStrings;
      command = baseCommand ++ (if isNixUpdate && !hasFlakeFlag then [ "--flake" ] else [ ]);
      contexts = builtins.getContext (builtins.concatStringsSep "" (map toString command));
      attrPath = if builtins.isAttrs update && update ? attrPath then update.attrPath else requestedAttrPath;
    in
    {
      inherit attrPath;
      command = map toString command;
      drvPaths = builtins.attrNames contexts;
      name = package.name;
      pname = package.pname;
      oldVersion = package.version;
    }
  '
)"

command=()
while IFS= read -r -d '' argument; do
  command+=("$argument")
done < <(jq -j '.command[] | . + "\u0000"' <<< "$data")

drv_paths=()
while IFS= read -r -d '' drv; do
  drv_paths+=("$drv")
done < <(jq -j '.drvPaths[] | . + "\u0000"' <<< "$data")
if ((${#drv_paths[@]})); then
  nix-store --realise "${drv_paths[@]}" >/dev/null
fi

IFS=$'\t' read -r name pname old_version attr_path < <(
  jq -r '[.name, .pname, .oldVersion, .attrPath] | @tsv' <<< "$data"
)
export UPDATE_NIX_NAME="$name"
export UPDATE_NIX_PNAME="$pname"
export UPDATE_NIX_OLD_VERSION="$old_version"
export UPDATE_NIX_ATTR_PATH="$attr_path"

exec "${command[@]}"
