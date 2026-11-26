# kings-canyon

Louis' home server

## Hardware

- Motherboard: ASRock Rack ROMED8-2T
- CPU: AMD EPYC 7443 (Milan / EPYC 7003)
- RAM: 96 GB
- GPUs:
    - 2x Nvidia RTX 3060 12GB
    - 1x Nvidia RTX 3090 24GB
- [Full parts list](https://pcpartpicker.com/user/dudeofawesome/saved/cF6wkL)

### Shared Steam library

The Wolf module also mounts a managed Sway rule at `/etc/sway/config.d/90-valheim.conf` in GOW Steam containers, independently of library sharing. Native Valheim uses the window class `valheim.x86_64`, which misses GOW's `steam_app_.*` rule and can remain hidden behind Steam Big Picture. The workaround makes Valheim fullscreen and focuses it on launch, preserving each profile's custom Sway configuration. Related fullscreen controls discussion: [games-on-whales/gow#304](https://github.com/games-on-whales/gow/issues/304). After deployment, restart Wolf and recreate Steam sessions to pick up the mount; Lauren's existing profile workaround can remain until then.

Wolf shares `/mnt/games/steamapps` between GOW Steam containers, including downloads, installation manifests, and Workshop content. Each app's existing home retains its Steam login, Proton prefixes (`.steam/debian-installation/steamapps/compatdata`), and shader cache. A container startup hook mounts the shared library and then mounts the private prefixes/cache over its corresponding directories, without moving or copying private files. Use separate Wolf profiles/app homes for separate users. App users need write access to the shared library, which defaults to UID/GID `1000:1000`.

On Wolf startup, the Nix module updates Steam runners in `/var/lib/wolf/cfg/config.toml`, preserving paired clients and other settings and saving the original once as `config.toml.before-shared-steam`. A missing config is initialized from the pinned Wolf source. Steam entries added through Wolf UI need a Wolf restart before the mounts are added; custom Steam images are not automatically modified.

Existing private game installations remain on disk underneath the shared mount. To reuse them, stop all Steam sessions and copy `common/`, `appmanifest_*.acf`, and any needed `workshop/` from one chosen installation into `/mnt/games/steamapps`, retaining ownership `1000:1000`. Do not copy `compatdata/` or `shadercache/`. Choose one installation as authoritative when versions differ. The September migration excluded installed games, so a fresh shared download is also expected here. Let only one Steam session install, update, or uninstall shared games at a time; an uninstall affects every user. Saves written directly into a game's installation directory are also shared.

The `/var/lib/kings-canyon/wolf-ready` GPU gate still applies. After deployment and GPU setup, verify with two profiles: install a game in one, check that the other recognizes it, and confirm that Proton prefixes/saves are separate. To disable sharing, stop sessions, disable the Nix option, and remove the `/var/lib/wolf-steamapps` and `/etc/cont-init.d/40-shared-steam.sh` mounts from Steam runners before restarting Wolf. Disabling the option alone does not undo changes to Wolf's mutable config.
