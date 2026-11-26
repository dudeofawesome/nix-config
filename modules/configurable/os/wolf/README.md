# Wolf Steam applications

Set `services.games-on-whales.wolf.steamRenderNode` to select a GPU for every GOW Steam app, including existing profile overrides. Prefer a stable path such as `/dev/dri/by-path/pci-0000:82:00.0-render`; Wolf startup resolves it to the current render node. Restart Wolf and recreate Steam sessions to use the selected GPU. Setting the option back to `null` preserves the assignments already saved in Wolf's configuration.

Enable Gale for selected Wolf profile IDs with `services.games-on-whales.wolf.gale.profiles = [ "lauren" ];`. This applies to the standard GOW Steam image; profile IDs are the `id` values in Wolf's configuration.

Nix downloads the official AppImage with a pinned checksum, extracts it during the build, and provides the application and its bundled libraries through read-only container mounts. Updating the version and hash in `gale.nix` updates the mounted application when Steam containers are recreated. Use Nix to update Gale; its in-app updater cannot replace the read-only application files.

Wolf's startup configuration adds mounts for selected Steam runners. A container initialization hook then creates the launcher and desktop entry and merges a Gale shortcut into each existing Steam account's library before Steam starts. Other shortcuts, custom Gale shortcut settings, and Gale's preferences and mod profiles are preserved. Existing shortcut files are backed up once as `shortcuts.vdf.before-gale` before their first change. Managed Sway rules show Gale fullscreen above Steam Big Picture.

Launch **Gale** from Steam's **Non-Steam** library. Its configuration and mod profiles stay in the app's persistent home. A new Steam account needs another session start after its first login before the hook can add its library shortcut.

For native Linux Valheim, set Steam's **Properties → General → Launch Options** to `./start_game_bepinex.sh %command%`, as described in the [BepInExPack Valheim instructions](https://thunderstore.io/c/valheim/p/denikson/BepInExPack_Valheim/). Launch modded games from Gale so it supplies the selected profile's preloader path. The script loads the native Doorstop library; Doorstop arguments alone do not load it. Do not paste the full `steam -applaunch` command into Steam's launch options.

After enabling or changing this configuration, restart Wolf and recreate affected Steam containers to pick up the mounts. Removing a profile from `gale.profiles` removes its Gale mounts from the runner on Wolf startup; existing shortcuts and Gale data remain in its home.
