"""Provision Gale in a Wolf Steam app home before Steam starts."""

import argparse
import os
from pathlib import Path
import shutil
import tempfile
import zlib

import vdf

CONTAINER_HOME = "/home/retro"
EXECUTABLE = f"{CONTAINER_HOME}/.local/bin/gale"
ICON = "/opt/wolf-gale/app/usr/share/icons/hicolor/128x128/apps/gale.png"
WRAPPER = b"""#!/bin/sh
set -eu
unset LD_PRELOAD LD_LIBRARY_PATH
# Gale treats the presence of this variable as Flatpak, including container=podman.
unset container
export APPDIR=/opt/wolf-gale/app
export WEBKIT_DISABLE_DMABUF_RENDERER=1
exec "$APPDIR/AppRun" "$@"
"""
DESKTOP = f"""[Desktop Entry]
Type=Application
Name=Gale
Comment=Thunderstore mod manager
Exec={EXECUTABLE} %U
Icon={ICON}
Categories=Game;
Terminal=false
MimeType=x-scheme-handler/ror2mm;x-scheme-handler/gale;application/x-r2z;
""".encode()


def shortcut():
    executable = f'"{EXECUTABLE}"'
    # ValvePython serializes int32 values as signed integers.
    app_id = (zlib.crc32((executable + "Gale").encode()) | 0x80000000) - 0x100000000
    return {
        "appid": app_id,
        "AppName": "Gale",
        "Exe": executable,
        "StartDir": f'"{CONTAINER_HOME}"',
        "icon": ICON,
        "ShortcutPath": "",
        "LaunchOptions": "",
        "IsHidden": 0,
        "AllowDesktopConfig": 1,
        "AllowOverlay": 0,
        "OpenVR": 0,
        "Devkit": 0,
        "DevkitGameID": "",
        "LastPlayTime": 0,
        "tags": {"0": "Mod managers"},
    }


def merge_shortcut(original):
    document = vdf.binary_loads(original) if original else {"shortcuts": {}}
    entries = document.setdefault("shortcuts", {})
    for entry in entries.values():
        keys = {key.lower(): key for key in entry}
        executable_key = keys.get("exe", "Exe")
        icon_key = keys.get("icon", "icon")
        if entry.get(executable_key, "").strip('"') == EXECUTABLE:
            # Keep the stable appid, custom name, tags, play time and settings.
            entry[executable_key] = f'"{EXECUTABLE}"'
            icon = entry.get(icon_key, "")
            if not icon or icon.startswith(("/opt/wolf-gale/", f"{CONTAINER_HOME}/.local/opt/gale/")):
                entry[icon_key] = ICON
            break
    else:
        key = str(max((int(key) for key in entries), default=-1) + 1)
        entries[key] = shortcut()
    return vdf.binary_dumps(document)


def write_owned(path, content, uid, gid, mode=0o644):
    if path.exists() and path.read_bytes() == content:
        return
    missing = []
    parent = path.parent
    while not parent.exists():
        missing.append(parent)
        parent = parent.parent
    for parent in reversed(missing):
        parent.mkdir()
        os.chown(parent, uid, gid)
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as stream:
        temporary = Path(stream.name)
        try:
            stream.write(content)
            stream.flush()
            os.fchmod(stream.fileno(), mode)
            os.fchown(stream.fileno(), uid, gid)
            os.replace(temporary, path)
        finally:
            temporary.unlink(missing_ok=True)


def configure(home, uid, gid):
    # Parse every account first: an invalid VDF must not be overwritten or
    # leave another account partially updated. Account 0 is Steam's template.
    updates = []
    for config in sorted((home / ".steam/steam/userdata").glob("*/config")):
        if not config.parent.name.isdigit() or int(config.parent.name) == 0:
            continue
        path = config / "shortcuts.vdf"
        original = path.read_bytes() if path.exists() else None
        result = merge_shortcut(original)
        if result != original:
            updates.append((path, original, result))
    write_owned(home / ".local/bin/gale", WRAPPER, uid, gid, 0o755)
    write_owned(home / ".local/share/applications/gale.desktop", DESKTOP, uid, gid)
    for path, original, result in updates:
        backup = path.with_name("shortcuts.vdf.before-gale")
        if original is not None and not backup.exists():
            shutil.copy2(path, backup)
            os.chown(backup, uid, gid)
        write_owned(path, result, uid, gid)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("home", type=Path)
    parser.add_argument("--uid", type=int, required=True)
    parser.add_argument("--gid", type=int, required=True)
    args = parser.parse_args()
    configure(args.home, args.uid, args.gid)


if __name__ == "__main__":
    main()
