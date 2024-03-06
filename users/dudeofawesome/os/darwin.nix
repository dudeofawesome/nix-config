{ pkgs, users, ... }: {
  homebrew = {
    casks =
      let
        skipSha = name: {
          inherit name;
          args = { require_sha = false; };
        };
        noQuarantine = name: {
          inherit name;
          args = { no_quarantine = true; };
        };
      in
      [
        "1password"
        "aerial"
        "affinity-photo"
        "arduino"
        "balenaetcher"
        "bartender"
        "bettertouchtool"
        "cyberduck"
        "displaylink"
        "docker"
        "figma"
        "firefox"
        "hammerspoon"
        "inkscape"
        "insomnia"
        "lulu"
        "parsec"
        "plex"
        "plexamp"
        "podman-desktop"
        "postico"
        "postman"
        "private-internet-access"
        "rectangle"
        "signal"
        "slack"
        "spotify"
        "steam"
        "stay"
        "tableplus"
        "typora"
        "utm"
        "visual-studio-code"
        "workman"
      ];
    masApps = {
      "1password for Safari" = 1569813296;
      "AdGuard for Safari" = 1440147259;
      # "Ubiquiti WiFiman" = 1385561119; # I keep on getting an error about the latest version being incompatible…
      "Microsoft Remote Desktop" = 1295203466;
    };
  };
}
