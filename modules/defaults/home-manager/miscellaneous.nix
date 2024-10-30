{ pkgs, lib, ... }:
{
  home = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = lib.mkDefault "23.05"; # Did you read the comment?

    packages = with pkgs; [ ];

    file = {
      prettierrc = {
        target = ".config/.prettierrc.js";
        source = "${pkgs.dotfiles.dudeofawesome}/home/.config/.prettierrc.js";
      };
    };
  };

  programs = {
    ssh = {
      enable = true;

      matchBlocks = {
        "git" = {
          match = "host *git*,*bitbucket*";
          user = "git";
        };
      };

      extraConfig = ''
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      '';
    };

    git = {
      enable = true;

      ignores = [
        ".DS_Store"
      ];

      signing = {
        signByDefault = true;
      };

      extraConfig = {
        gpg = {
          format = "ssh";
        };

        "gpg \"ssh\"" = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    tmux = {
      enable = true;

      # clock24 = true;
      extraConfig = builtins.readFile "${pkgs.dotfiles.dudeofawesome}/home/.config/tmux/tmux.conf";
    };

    doa-system-clock.enable = true;
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
      # keybindings = {
      #   "~f" = "moveWordForward:";
      # };

      defaults = {
        "com.apple.finder" = {
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
          # Use columns view
          FXPreferredViewStyle = "clmv";
        };

        "com.apple.Siri".StatusMenuVisible = 0;

        # "com.apple.Terminal" = { };

        "com.apple.dock" = {
          showAppExposeGestureEnabled = 1;
          showDesktopGestureEnabled = 1;
          showLaunchpadGestureEnabled = 1;
          showMissionControlGestureEnabled = 1;
        };
        # dock = {
        #   showAppExposeGestureEnabled = 1;
        #   showMissionControlGestureEnabled = 1;
        # };

        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 1;
        };

        "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
          TrackpadFiveFingerPinchGesture = 2;
          TrackpadFourFingerHorizSwipeGesture = 2;
          TrackpadFourFingerPinchGesture = 2;
          TrackpadFourFingerVertSwipeGesture = 2;
          TrackpadThreeFingerHorizSwipeGesture = 1;
          TrackpadThreeFingerTapGesture = 0;
          TrackpadThreeFingerVertSwipeGesture = 1;
        };

        "com.apple.iCal".ShowDeclinedEvents = 1;

        "com.apple.mail" = {
          # Set left swipe to archive
          SwipeAction = 1;

          "NSToolbar Configuration MainWindow" = {
            "TB Item Identifiers" = [
              "saveSearch:"
              "toggleMessageListFilter:"
              "SeparatorToolbarItem"
              "checkNewMail:"
              "showComposeWindow:"
              "NSToolbarFlexibleSpaceItem"
              "archiveMessages:"
              "deleteMessages:"
              "reply_replyAll_forward"
              "FlaggedStatus"
              "toggleAllHeaders:"
              "NSToolbarFlexibleSpaceItem"
              "Search"
            ];
          };

        };

        "com.apple.Spotlight" = {
          orderedItems = [
            {
              enabled = 1;
              name = "APPLICATIONS";
            }
            {
              enabled = 1;
              name = "BOOKMARKS";
            }
            {
              enabled = 1;
              name = "MENU_EXPRESSION";
            }
            {
              enabled = 1;
              name = "CONTACT";
            }
            {
              enabled = 1;
              name = "MENU_CONVERSION";
            }
            {
              enabled = 1;
              name = "MENU_DEFINITION";
            }
            {
              enabled = 1;
              name = "SOURCE";
            }
            {
              enabled = 1;
              name = "DOCUMENTS";
            }
            {
              enabled = 1;
              name = "EVENT_TODO";
            }
            {
              enabled = 1;
              name = "DIRECTORIES";
            }
            {
              enabled = 1;
              name = "FONTS";
            }
            {
              enabled = 1;
              name = "IMAGES";
            }
            {
              enabled = 1;
              name = "MESSAGES";
            }
            {
              enabled = 1;
              name = "MOVIES";
            }
            {
              enabled = 1;
              name = "MUSIC";
            }
            {
              enabled = 1;
              name = "MENU_OTHER";
            }
            {
              enabled = 1;
              name = "PDF";
            }
            {
              enabled = 1;
              name = "PRESENTATIONS";
            }
            {
              enabled = 0;
              name = "MENU_SPOTLIGHT_SUGGESTIONS";
            }
            {
              enabled = 1;
              name = "SPREADSHEETS";
            }
            {
              enabled = 1;
              name = "SYSTEM_PREFS";
            }
            {
              enabled = 1;
              name = "TIPS";
            }
          ];
        };

        "com.apple.networkConnect" = {
          VPNShowTime = 1;
        };

        "com.apple.systemuiserver" = {
          "NSStatusItem Visible com.apple.menuextra.vpn" = 1;
          "NSStatusItem Visible Bluetooth" = 1;
          menuExtras = (
            "/System/Library/CoreServices/Menu Extras/VPN.menu"
          );
        };

        "com.spotify.client".AutoStartSettingIsHidden = 0;

        "com.apple.Safari".IncludeDevelopMenu = true;
        "com.apple.dock".size-immutable = true;
      };

      currentHostDefaults = {
        "com.apple.controlcenter".BatteryShowPercentage = true;
      };
    };
  };

  # TODO: figure out a better solution
  # This cleans up a bunch of symlinks the macOS Docker Desktop app makes which
  #   override the versions we install with Nix
  home.activation.cleanupDockerDesktop = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin ''
    cd /usr/local/bin/
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD sudo rm -f \
      docker \
      docker-compose \
      docker-index \
      kubectl \
      kubectl.docker \
      ;
  '';

  home.activation.zzActivateSettings = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin ''
    $DRY_RUN_CMD /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD killall Dock ControlCenter
  '';
}
