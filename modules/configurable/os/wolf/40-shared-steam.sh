#!/usr/bin/env bash
# Sourced by GOW's root entrypoint after user setup, before Steam starts.
set -e

wolf_steam_home=/home/retro/.steam/debian-installation
wolf_steam_apps="$wolf_steam_home/steamapps"
wolf_steam_private=/tmp/wolf-steam-private

# Create only these directories; never recursively chown an existing library.
install -d -o "${PUID:-1000}" -g "${PGID:-1000}" \
    /home/retro/.steam "$wolf_steam_home" "$wolf_steam_apps" \
    "$wolf_steam_apps/compatdata" "$wolf_steam_apps/shadercache"
mkdir -p "$wolf_steam_private/compatdata" "$wolf_steam_private/shadercache"

# Keep references to the private directories before covering steamapps.
# These bind mounts live only inside this container's mount namespace.
for wolf_steam_part in compatdata shadercache; do
    mount --bind "$wolf_steam_apps/$wolf_steam_part" \
        "$wolf_steam_private/$wolf_steam_part"
done
mount --bind /var/lib/wolf-steamapps "$wolf_steam_apps"
for wolf_steam_part in compatdata shadercache; do
    mount --bind "$wolf_steam_private/$wolf_steam_part" \
        "$wolf_steam_apps/$wolf_steam_part"
done
