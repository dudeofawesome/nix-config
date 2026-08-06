{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.jovian;
in
{
  # TODO: support other DEs
  jovian.steam.desktopSession =
    if config.services.desktopManager.gnome.enable then "gnome" else "gamescope-wayland";

  # TODO: remove this backport https://github.com/SteamDeckHomebrew/decky-loader/pull/827
  jovian.decky-loader.package = lib.mkIf cfg.decky-loader.enable (
    pkgs.decky-loader.overridePythonAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./decky-loader-respect-path.patch ];
    })
  );

  # TODO: remove once decky-loader upgrades pnpm
  nixpkgs.config.permittedInsecurePackages = lib.mkIf cfg.decky-loader.enable [ "pnpm-9.15.9" ];

  # https://jovian-experiments.github.io/Jovian-NixOS/in-depth/decky-loader.html
  # Create Steam CEF debugging file if it doesn't exist for Decky Loader.
  systemd.services.steam-cef-debug = lib.mkIf cfg.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      Type = "oneshot";
      User = config.jovian.steam.user;
      ExecStart = "/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Game Mode owns the graphical session; GDM from the PC machine class would
  #   conflict with Jovian's autostart service.
  services.displayManager.gdm.enable = lib.mkIf cfg.steam.autoStart false;

  # fixes gnome startup
  systemd.user.services.steamos-manager.environment.XDG_DATA_DIRS = lib.mkIf (
    cfg.steam.desktopSession == "gnome"
  ) "${config.services.displayManager.sessionData.desktops}/share";
}
