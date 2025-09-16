{ pkgs, lib, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      ntfs3g
    ];
  };

  homebrew = {
    casks = [
      "1password"
      "android-file-transfer"
      "arduino-ide"
      "background-music"
      "balenaetcher"
      "bettertouchtool"
      "cleanmymac"
      "cursor"
      "cyberduck"
      "daisydisk"
      "discord"
      "electrum"
      "figma" # TODO: maybe this should be part of the Paciolan nix script
      "gifox"
      "google-drive"
      "google-earth-pro"
      "handbrake"
      "jordanbaird-ice"
      "launchcontrol"
      "lm-studio"
      "logi-options+"
      "macfuse"
      "messenger"
      "microsoft-remote-desktop"
      "miro"
      "monitorcontrol"
      "mounty"
      "obs"
      "openra"
      "parsec"
      "plex"
      "postico"
      "private-internet-access"
      "raycast"
      "rocket"
      "signal"
      "spotify"
      "stay"
      "steam"
      "thinkorswim"
      "todoist"
      "transmission"
      "ultimaker-cura"
      "visual-studio-code"
      "vlc"
      "webull"
      "wireshark"
      "zoom"
    ];
    masApps = {
      # "Ubiquiti WiFiman" = 1385561119; # I keep on getting an error about the latest version being incompatible…
      "Microsoft Remote Desktop" = 1295203466;
      "Microsoft Outlook" = 985367838;
      "Steam Link" = 1246969117;
      "Little Snitch Mini" = 1629008763;
    };
  };

  system = {
    keyboard = {
      remapCapsLockToEscape = lib.mkForce false;
    };
  };
}
