{ pkgs, lib, ... }: {
  environment = {
    systemPackages = with pkgs; [
      ntfs3g
    ];
  };

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
      "macfuse"
      "messenger"
      "microsoft-remote-desktop"
      "miro"
      "mounty"
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
    keyboard = {
      remapCapsLockToEscape = lib.mkForce false;
    };
  };
}
