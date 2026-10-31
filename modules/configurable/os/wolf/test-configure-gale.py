"""Run with Python and vdf: python test-configure-gale.py."""

import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import vdf

SCRIPT = Path(__file__).with_name("configure-gale.py")
SPEC = importlib.util.spec_from_file_location("configure_gale", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ConfigureGaleTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.home = Path(self.temporary.name)
        self.path = self.account("123")

    def account(self, name):
        path = self.home / f".steam/steam/userdata/{name}/config/shortcuts.vdf"
        path.parent.mkdir(parents=True)
        return path

    def configure(self):
        MODULE.configure(self.home, os.getuid(), os.getgid())

    def test_existing_shortcuts_and_backup_survive_repeated_runs(self):
        other = {
            "AppName": "Other — game",
            "Exe": '"/games/other"',
            "LaunchOptions": "--custom",
            "tags": {"0": "Favorites"},
            "SomeFutureField": vdf.UINT_64(2**40),
        }
        original = vdf.binary_dumps({"shortcuts": {"0": other}})
        self.path.write_bytes(original)
        self.configure()
        first = self.path.read_bytes()
        entries = vdf.binary_loads(first)["shortcuts"]
        self.assertEqual(entries["0"], other)
        self.assertEqual(entries["1"]["AppName"], "Gale")
        self.assertEqual(entries["1"]["Exe"], f'"{MODULE.EXECUTABLE}"')
        backup = self.path.with_name("shortcuts.vdf.before-gale")
        self.assertEqual(backup.read_bytes(), original)
        before = self.path.stat().st_mtime_ns
        self.configure()
        self.assertEqual(self.path.read_bytes(), first)
        self.assertEqual(self.path.stat().st_mtime_ns, before)
        self.assertEqual(backup.read_bytes(), original)

    def test_upgrades_keep_custom_gale_settings_and_stable_appid(self):
        gale = MODULE.shortcut()
        gale.update({
            "AppName": "My Gale",
            "LastPlayTime": 12345,
            "LaunchOptions": "--custom",
            "tags": {"0": "Favorites"},
            "icon": "/home/retro/.local/opt/gale/old/icon.png",
        })
        self.path.write_bytes(vdf.binary_dumps({"shortcuts": {"0": gale}}))
        self.configure()
        result = vdf.binary_loads(self.path.read_bytes())["shortcuts"]
        self.assertEqual(len(result), 1)
        self.assertEqual(result["0"], gale | {"icon": MODULE.ICON})

    def test_multiple_accounts_and_first_login(self):
        second = self.account("456")
        template = self.account("0")
        self.configure()
        for path in (self.path, second):
            entries = vdf.binary_loads(path.read_bytes())["shortcuts"]
            self.assertEqual(len(entries), 1)
        self.assertFalse(template.exists())
        self.assertFalse(self.path.with_name("shortcuts.vdf.before-gale").exists())
        third = self.account("789")
        self.configure()
        self.assertTrue(third.exists())

    def test_steam_field_capitalization_and_custom_icon_are_preserved(self):
        gale = {key.lower(): value for key, value in MODULE.shortcut().items()}
        gale["icon"] = "/home/retro/Pictures/my-gale-icon.png"
        self.path.write_bytes(vdf.binary_dumps({"shortcuts": {"0": gale}}))
        self.configure()
        entries = vdf.binary_loads(self.path.read_bytes())["shortcuts"]
        self.assertEqual(entries, {"0": gale})

    def test_launcher_and_data_are_preserved(self):
        data = self.home / ".config/com.kesomannen.gale/profiles.json"
        data.parent.mkdir(parents=True)
        data.write_text("user's mod profiles")
        self.configure()
        launcher = self.home / ".local/bin/gale"
        self.assertEqual(launcher.stat().st_mode & 0o777, 0o755)
        self.assertEqual(launcher.stat().st_uid, os.getuid())
        self.assertIn(b"/opt/wolf-gale/app", launcher.read_bytes())
        self.assertEqual(data.read_text(), "user's mod profiles")
        before = launcher.stat().st_mtime_ns
        self.configure()
        self.assertEqual(launcher.stat().st_mtime_ns, before)

    def test_launcher_clears_podmans_false_flatpak_detection(self):
        # Inspect the environment handed to AppRun without launching the UI.
        wrapper = MODULE.WRAPPER.decode().replace(
            'exec "$APPDIR/AppRun" "$@"', 'exec /usr/bin/env'
        )
        result = subprocess.run(
            ["/bin/sh", "-c", wrapper],
            env=os.environ | {"container": "podman", "DISPLAY": ":42"},
            capture_output=True, text=True, check=True,
        )
        environment = dict(line.split("=", 1) for line in result.stdout.splitlines())
        self.assertNotIn("container", environment)
        self.assertEqual(environment["DISPLAY"], ":42")
        self.assertEqual(environment["APPDIR"], "/opt/wolf-gale/app")

    def test_invalid_shortcuts_abort_before_changing_any_account(self):
        invalid = self.account("456")
        invalid.write_bytes(b"invalid VDF")
        with self.assertRaises((SyntaxError, ValueError)):
            self.configure()
        self.assertFalse(self.path.exists())
        self.assertEqual(invalid.read_bytes(), b"invalid VDF")
        self.assertFalse((self.home / ".local").exists())

    def test_home_without_steam_login_still_gets_a_launcher(self):
        self.path.parent.rmdir()
        self.configure()
        self.assertTrue((self.home / ".local/bin/gale").exists())
        self.assertFalse(self.path.exists())


if __name__ == "__main__":
    unittest.main()
