"""Run with Python and tomlkit: python -m unittest discover -p 'test-*.py'."""

import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import tomlkit

SCRIPT = Path(__file__).with_name("configure-steam.py")
SPEC = importlib.util.spec_from_file_location("configure_steam", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
FIXTURE = '''# Preserve this comment and paired client.
uuid = "existing-host"
paired_clients = [{client_cert = "certificate", app_state_folder = "alice"}]
[[profiles]]
id = "alice"
[[profiles.apps]]
title = "Steam"
[profiles.apps.runner]
type = "docker"
image = "ghcr.io/games-on-whales/steam:edge"
mounts = ["/run/udev:/run/udev:ro"]
env = ["RUN_SWAY=true"]
base_create_json = '{"HostConfig":{"IpcMode":"host","CapAdd":["SYS_NICE"]}}'
[[profiles.apps]]
title = "Other"
[profiles.apps.runner]
type = "process"
run_cmd = "true"
'''


class ConfigureSteamTests(unittest.TestCase):
    def test_preserves_settings_and_is_idempotent(self):
        original = tomlkit.parse(FIXTURE)
        result = MODULE.configure(tomlkit.parse(FIXTURE), "/games", "/hook")
        self.assertEqual(result["paired_clients"], original["paired_clients"])
        self.assertEqual(result["uuid"], original["uuid"])
        apps = result["profiles"][0]["apps"]
        self.assertEqual(apps[1], original["profiles"][0]["apps"][1])
        self.assertEqual(apps[0]["runner"]["env"], ["RUN_SWAY=true"])
        self.assertIn("/run/udev:/run/udev:ro", apps[0]["runner"]["mounts"])
        options = json.loads(apps[0]["runner"]["base_create_json"])
        self.assertEqual(options["HostConfig"]["IpcMode"], "host")
        self.assertEqual(options["HostConfig"]["CapAdd"], ["SYS_NICE", "SYS_ADMIN"])
        first = tomlkit.dumps(result)
        self.assertIn("# Preserve this comment", first)
        self.assertEqual(first, tomlkit.dumps(MODULE.configure(result, "/games", "/hook")))

    def test_legacy_apps_and_multiple_profiles(self):
        doc = tomlkit.parse(FIXTURE)
        doc["apps"] = doc["profiles"][0]["apps"].unwrap()
        doc["profiles"].append(doc["profiles"][0].unwrap())
        result = MODULE.configure(doc, "/games", "/hook")
        for apps in [result["apps"]] + [p["apps"] for p in result["profiles"]]:
            self.assertIn("/games:/var/lib/wolf-steamapps:rw", apps[0]["runner"]["mounts"])

    def test_atomic_backup_and_conflict(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "config.toml"
            config.write_text(FIXTURE)
            command = [sys.executable, str(SCRIPT), str(config), "unused", "/games", "/hook"]
            subprocess.run(command, check=True)
            self.assertEqual(config.with_name("config.toml.before-shared-steam").read_text(), FIXTURE)
            conflict = FIXTURE.replace(
                "/run/udev:/run/udev:ro",
                "/old:/home/retro/.steam/debian-installation/steamapps:rw",
            )
            config.write_text(conflict)
            result = subprocess.run(command, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(config.read_text(), conflict)
            self.assertEqual(config.with_name("config.toml.before-shared-steam").read_text(), FIXTURE)

    def test_first_boot(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "cfg/config.toml"
            default = Path(directory) / "default.toml"
            default.write_text('R"for_c++_include(' + FIXTURE + ')for_c++_include"')
            command = [sys.executable, str(SCRIPT), str(config), str(default), "/games", "/hook"]
            subprocess.run(command, check=True)
            first = config.read_text()
            self.assertNotEqual(tomlkit.parse(first)["uuid"], "existing-host")
            subprocess.run(command, check=True)
            self.assertEqual(config.read_text(), first)
            self.assertFalse(config.with_name("config.toml.before-shared-steam").exists())


if __name__ == "__main__":
    unittest.main()
