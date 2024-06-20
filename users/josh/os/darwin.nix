{ pkgs, lib, ... }: {
  homebrew = {
    casks = [
      "1password"
      "android-file-transfer"
      "background-music"
      "balenaetcher"
      "barrier"
      "bettertouchtool"
      "cyberduck"
      "docker"
      "electrum"
      "figma"
      "gifox"
      "google-drive"
      "google-earth-pro"
      "handbrake"
      "jordanbaird-ice"
      "messenger"
      "microsoft-remote-desktop"
      "miro"
      "obs"
      "omnidisksweeper"
      "openra"
      "parsec"
      "plex"
      "postico"
      "postman"
      "private-internet-access"
      "raycast"
      "rocket"
      "signal"
      "slack"
      "spotify"
      "stay"
      "steam"
      "tableplus"
      "thinkorswim"
      "todoist"
      "transmission"
      "visual-studio-code"
      "vlc"
      "webull"
      "wireshark"
    ];
    masApps = {
      # "Ubiquiti WiFiman" = 1385561119; # I keep on getting an error about the latest version being incompatible…
      "Microsoft Remote Desktop" = 1295203466;
      "Microsoft Outlook" = 985367838;
    };
  };

  system = {
    defaults = {
      dock = {
        minimize-to-application = lib.mkForce false;

        wvous-br-corner = 14; # Quick Note
      };
      finder = {
        AppleShowAllFiles = lib.mkForce false;
      };
    };

    keyboard = {
      remapCapsLockToEscape = lib.mkForce false;
    };
  };
}
