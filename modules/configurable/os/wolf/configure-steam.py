"""Configure Steam and XFCE mounts while preserving Wolf's mutable configuration."""

import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import uuid

import tomlkit


def configure(document, library, hook, sway_config):
    apps = list(document.get("apps", []))
    for profile in document.get("profiles", []):
        apps.extend(profile.get("apps", []))
    for app in apps:
        runner = app.get("runner", {})
        image = runner.get("image", "")
        if runner.get("type", "").lower() != "docker":
            continue
        is_steam = image.startswith("ghcr.io/games-on-whales/steam:")
        is_xfce = image.startswith("ghcr.io/games-on-whales/xfce:")
        if not is_steam and not (is_xfce and library):
            continue
        mounts = runner.setdefault("mounts", [])
        managed_mounts = []
        if is_steam:
            managed_mounts.append((sway_config, "/etc/sway/config.d/90-valheim.conf", "ro"))
        if library:
            managed_mounts.append((library, "/home/retro/Games/Steam/steamapps", "rw"))
        if library and is_steam:
            managed_mounts.extend([
                (library, "/var/lib/wolf-steamapps", "rw"),
                (hook, "/etc/cont-init.d/40-shared-steam.sh", "ro"),
            ])
        if is_xfce:
            env = runner.setdefault("env", [])
            for variable in list(env):
                if variable.startswith("STEAM_DIR="):
                    env.remove(variable)
            env.append("STEAM_DIR=/home/retro/Games/Steam")
        for source, destination, mode in managed_mounts:
            # Replace only mounts owned by this module. An old direct library
            # mount would hide private prefixes before our hook can save them.
            for mount in list(mounts):
                target = mount.split(":")[1].rstrip("/")
                if library and is_steam and target in (
                    "/home/retro/.steam/steam/steamapps",
                    "/home/retro/.steam/debian-installation/steamapps",
                ):
                    raise ValueError("Remove the existing direct steamapps mount first")
                if target == destination:
                    mounts.remove(mount)
            mounts.append(f"{source}:{destination}:{mode}")
        if library and is_steam:
            options = json.loads(runner.get("base_create_json", "{}"))
            caps = options.setdefault("HostConfig", {}).setdefault("CapAdd", [])
            if "SYS_ADMIN" not in caps:
                caps.append("SYS_ADMIN")
            runner["base_create_json"] = json.dumps(options)
    return document


def main():
    config, default, library, hook, sway_config = sys.argv[1:]
    path = Path(config)
    original = path.read_text() if path.exists() else None
    if original is None:
        # Wolf embeds its default TOML inside a C++ raw string.
        text = Path(default).read_text().strip()
        text = text.removeprefix('R"for_c++_include(').removesuffix(')for_c++_include"')
        document = tomlkit.parse(text)
        document["uuid"] = str(uuid.uuid4())
    else:
        document = tomlkit.parse(original)
    result = tomlkit.dumps(configure(document, library, hook, sway_config))
    if result == original:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    backup = path.with_name("config.toml.before-shared-steam")
    if original is not None and not backup.exists():
        shutil.copy2(path, backup)
    descriptor, temporary = tempfile.mkstemp(dir=path.parent, prefix=".config-")
    try:
        with os.fdopen(descriptor, "w") as stream:
            stream.write(result)
        if path.exists():
            stat = path.stat()
            os.chmod(temporary, stat.st_mode)
            os.chown(temporary, stat.st_uid, stat.st_gid)
        os.replace(temporary, path)
    finally:
        Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    main()
