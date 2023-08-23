{ config, pkgs, users, ... }: {
  users.users = builtins.mapAttrs
    (key: val: {
      home = "/Users/${key}";
      shell = pkgs.${val.shell};
    })
    users;

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      coreutils-prefixed
      darwin.lsusb
    ];
  };

  homebrew = {
    # Declare Homebrew using Nix-Darwin
    enable = true;
    # caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = false; # Auto update packages
      upgrade = false;
      cleanup = "zap"; # Uninstall not listed packages and casks
    };
    taps = [
    ];
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
        "1password-cli"
        "1password"
        "aerial"
        "affinity-photo"
        "bartender"
        "bettertouchtool"
        "cyberduck"
        "dash"
        "discord"
        "displaylink"
        "docker"
        "figma"
        "finicky"
        "firefox"
        "fork"
        "gitup"
        "google-chrome"
        "hammerspoon"
        "hex-fiend"
        "iina"
        "inkscape"
        "iterm2"
        "keka"
        "lulu"
        "parsec"
        "plex"
        "plexamp"
        "podman-desktop"
        "postico"
        "postman"
        (noQuarantine "qlcolorcode")
        (noQuarantine "qlmarkdown")
        (noQuarantine "qlstephen")
        (noQuarantine "qlvideo")
        "quicklook-json"
        "rectangle"
        "signal"
        "slack"
        "spotify"
        "stay"
        "sublime-merge"
        "sublime-text"
        "tableplus"
        "utm"
        "visual-studio-code"
        "workman"
      ];
    masApps = {
      "1password for Safari" = 1569813296;
      "Amphetamine" = 937984704;
      # "Ubiquiti WiFiman" = 1385561119; # I keep on getting an error about the latest version being incompatible…
      "Xcode" = 497799835;
      "Microsoft Remote Desktop" = 1295203466;
    };
  };

  system = {
    defaults = {
      # Global macOS system settings
      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
        AppleShowScrollBars = "WhenScrolling";

        AppleEnableMouseSwipeNavigateWithScrolls = true;

        AppleShowAllExtensions = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        AppleInterfaceStyleSwitchesAutomatically = true;

        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
      };
      dock = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        tilesize = 40;
        minimize-to-application = true;
        mru-spaces = false;

        wvous-tl-corner = 4; # Desktop
        wvous-br-corner = 14; # Quick Note
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      # menuExtraClock = {
      #   Show24Hour = true;
      #   ShowDate = 0;
      #   ShowDayOfMonth = true;
      #   ShowDayOfWeek = true;
      #   ShowSeconds = true;
      # };

      CustomSystemPreferences = {
        NSGlobalDomain = {
          "com.apple.mouse.scaling" = "0.875";
          "com.apple.trackpad.scaling" = "1.5";
          "com.apple.trackpad.threeFingerHorizSwipeGesture" = 1;
          "com.apple.AppleMultitouchTrackpad.TrackpadFourFingerHorizSwipeGesture" = 2;
          "com.apple.AppleMultitouchTrackpad.TrackpadFourFingerVertSwipeGesture" = 2;
          "com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerHorizSwipeGesture" = true;
          "com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerVertSwipeGesture" = true;
        };

        dock = {
          showAppExposeGestureEnabled = true;
          showMissionControlGestureEnabled = true;
        };
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          # NSUserDictionaryReplacementItems =
          #   let
          #     on = input:
          #       {
          #         on = 1;
          #         replace = builtins.elemAt input 0;
          #         "with" = builtins.elemAt input 1;
          #       };
          #   in
          #   [
          #     (on [ "fuck" "fuck" ])
          #     (on [ "suck" "suck" ])
          #     (on [ "fucking" "fucking" ])
          #     # 😀
          #     (on [ ":D" "\\Ud83d\\Ude00" ])
          #     # 😛
          #     (on [ ":p" "\\Ud83d\\Ude1b" ])
          #     (on [ "idk" "IDK" ])
          #     (on [ "*plusminus" "\\U00b1" ])
          #     (on [ "gql" "GraphQL" ])
          #     (on [ "omw" "on my way" ])
          #     # ( ͡° ͜ʖ ͡°)
          #     (on [ "*lenny" "( \\U0361\\U00b0 \\U035c\\U0296 \\U0361\\U00b0)" ])
          #     # (╯°□°)╯︵ ┻━┻
          #     (on [ "*tableflip" "(\\U256f\\U00b0\\U25a1\\U00b0)\\U256f\\Ufe35 \\U253b\\U2501\\U253b" ])
          #     # ¯\_(ツ)_/¯
          #     (on [ "*shruggie" "\\U00af\\\\_(\\U30c4)_/\\U00af" ])
          #     # ( ಠ ಠ )
          #     (on [ "*confused" "( \\U0ca0 \\U0ca0 )" ])
          #   ];

          # NSUserKeyEquivalents = {
          #   "Look Up in Dash" = "^h";
          #   "Show Next Tab" = "@~\\U2192";
          #   "Show Previous Tab" = "@~\\U2190";
          # };
        };
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    # Used for backwards compatibility, please read the changelog before changing.
    stateVersion = 4;
  };
}
