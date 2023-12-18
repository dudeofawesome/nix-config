{ pkgs, ... }: {
  imports = [
    ../../modules/machine-classes/base.darwin.nix
    ../../modules/auth.darwin.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      coreutils-prefixed
      darwin.lsusb

      # TODO: move some of these tools to home-manager, in a "work" module
      docker
      findutils
      gitlab-runner
      glab
      gnused
      gnutar
      iina
      podman
      podman-compose
      watch
    ];
  };

  services = {
    nix-daemon.enable = true; # Auto upgrade daemon
  };

  nix = {
    gc = {
      # TODO: how do we specify GC interval for nixos?
      interval.Day = 7;
    };
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
        "dash"
        "discord"
        "displaylink"
        "finicky"
        "firefox"
        "fork"
        "gitup"
        "google-chrome"
        "hex-fiend"
        "iterm2"
        "keka"
        (noQuarantine "qlcolorcode")
        (noQuarantine "qlmarkdown")
        (noQuarantine "qlstephen")
        (noQuarantine "qlvideo")
        (noQuarantine "quicklook-json")
        "sublime-text"
        "workman"
      ];
    masApps = {
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
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
        AppleKeyboardUIMode = 3;

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
          NSQuitAlwaysKeepsWindows = 1;

          # NSUserDictionaryReplacementItems =
          #   map
          #     (input:
          #       {
          #         on = 1;
          #         replace = builtins.elemAt input 0;
          #         "with" = builtins.elemAt input 1;
          #       })
          #     [
          #       [ "fuck" "fuck" ]
          #       [ "suck" "suck" ]
          #       [ "fucking" "fucking" ]
          #       [ ":D" "\\Ud83d\\Ude00" ] # 😀
          #       [ ":p" "\\Ud83d\\Ude1b" ] # 😛
          #       [ "idk" "IDK" ]
          #       [ "*plusminus" "\\U00b1" ]
          #       [ "gql" "GraphQL" ]
          #       [ "omw" "on my way" ]
          #       [ "*lenny" "( \\U0361\\U00b0 \\U035c\\U0296 \\U0361\\U00b0)" ] # ( ͡° ͜ʖ ͡°)
          #       [ "*tableflip" "(\\U256f\\U00b0\\U25a1\\U00b0)\\U256f\\Ufe35 \\U253b\\U2501\\U253b" ] # (╯°□°)╯︵ ┻━┻
          #       [ "*shruggie" "\\U00af\\\\_(\\U30c4)_/\\U00af" ] # ¯\_(ツ)_/¯
          #       [ "*confused" "( \\U0ca0 \\U0ca0 )" ] # ( ಠ ಠ )
          #     ];

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
