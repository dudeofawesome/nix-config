{ pkgs, lib, ... }: {
  homebrew = {
    casks = [
      "android-file-transfer"
      "background-music"
      "balenaetcher"
      "barrier"
      "bettertouchtool"
      "cyberduck"
      "electrum"
      "figma"
      "gifox"
      "google-drive"
      "google-earth-pro"
      "handbrake"
      "hiddenbar"
      "linearmouse"
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
      "1password for Safari" = 1569813296;
      "AdGuard for Safari" = 1440147259;
      # "Ubiquiti WiFiman" = 1385561119; # I keep on getting an error about the latest version being incompatible…
      "Microsoft Remote Desktop" = 1295203466;
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
