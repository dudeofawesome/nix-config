{ pkgs, users, machine-class, ... }: {
  imports = [ ] ++ (if (machine-class == "pc") then [
    ../../../modules/presets/os/paciolan.nix
  ] else [ ]);

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
        "affinity-photo"
        "arduino"
        "balenaetcher"
        "bettertouchtool"
        "dash"
        "displaylink"
        "docker"
        "figma"
        "firefox"
        "hammerspoon"
        "jordanbaird-ice"
        "logitech-g-hub"
        "lulu"
        (noQuarantine "middleclick")
        "mitmproxy"
        "parsec"
        "plex"
        "plexamp"
        "podman-desktop"
        "postico"
        "private-internet-access"
        "steam"
        "stay"
        "typora"
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
