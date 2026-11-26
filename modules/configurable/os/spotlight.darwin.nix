{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.spotlight;
  reconcile = pkgs.writeShellScript "reconcile-spotlight-exclusions" ''
    # macOS Bash 3.2 treats empty arrays as unset with `set -u`.
    set -eo pipefail
    umask 077

    spotlightStateDir=/var/db/nix-spotlight
    spotlightStateFile="$spotlightStateDir/excluded-volumes"
    spotlightPrevious=()
    spotlightDesired=( ${lib.escapeShellArgs cfg.excludedVolumes} )

    if [[ -f "$spotlightStateFile" ]]; then
      while IFS= read -r -d "" spotlightVolume; do
        spotlightPrevious+=( "$spotlightVolume" )
      done < "$spotlightStateFile"
    fi

    spotlightContains() {
      local needle="$1"
      shift
      local volume
      for volume in "$@"; do
        [[ "$volume" != "$needle" ]] || return 0
      done
      return 1
    }

    spotlightMdutil() {
      local output status
      if output=$(/usr/bin/mdutil "$@" 2>&1); then
        return 0
      else
        status=$?
        printf '%s\n' "$output" >&2
        return "$status"
      fi
    }

    /bin/mkdir -p "$spotlightStateDir"
    spotlightTemporaryFile=$(/usr/bin/mktemp "$spotlightStateDir/excluded-volumes.XXXXXX")
    trap '/bin/rm -f "$spotlightTemporaryFile"' EXIT

    # Journal both lists before changing indexing, so interrupted activations
    # retain enough information to restore any volumes they touched.
    for spotlightVolume in "''${spotlightPrevious[@]}"; do
      printf '%s\0' "$spotlightVolume"
    done > "$spotlightTemporaryFile"
    for spotlightVolume in "''${spotlightDesired[@]}"; do
      if ! spotlightContains "$spotlightVolume" "''${spotlightPrevious[@]}"; then
        printf '%s\0' "$spotlightVolume" >> "$spotlightTemporaryFile"
      fi
    done
    /bin/mv -f "$spotlightTemporaryFile" "$spotlightStateFile"

    for spotlightVolume in "''${spotlightPrevious[@]}"; do
      if ! spotlightContains "$spotlightVolume" "''${spotlightDesired[@]}"; then
        spotlightMdutil -i on "$spotlightVolume"
      fi
    done
    for spotlightVolume in "''${spotlightDesired[@]}"; do
      spotlightMdutil -d "$spotlightVolume"
    done

    spotlightTemporaryFile=$(/usr/bin/mktemp "$spotlightStateDir/excluded-volumes.XXXXXX")
    for spotlightVolume in "''${spotlightDesired[@]}"; do
      printf '%s\0' "$spotlightVolume"
    done > "$spotlightTemporaryFile"
    /bin/mv -f "$spotlightTemporaryFile" "$spotlightStateFile"
  '';
in
{
  options.services.spotlight.excludedVolumes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "/nix" ];
    description = ''
      Mounted volume paths for which Spotlight indexing and searching are
      disabled during activation. Entries must refer to volume mount points,
      not arbitrary directories. This does not manage the Spotlight Privacy list.

      Volumes previously managed by this module are re-enabled when removed
      from this list, including when the list becomes empty. This enables
      indexing even if the volume was already excluded before it was managed.
      Removing the module itself does not restore indexing; activate an empty
      list first. Previously managed volumes must be mounted during activation.
    '';
  };

  config = {
    system.activationScripts.postActivation.text = lib.mkAfter ''
      ${reconcile}
    '';
  };
}
