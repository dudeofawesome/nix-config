{ pkgs
, lib
, osConfig
, dotfiles
, ...
}:
{
  imports = [
    ./shells.nix
    ./editors.nix
  ];

  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      atuin
      bat
      bottom
      most
      ripgrep
    ];

    file = {
      prettierrc = {
        target = ".config/.prettierrc.js";
        source = "${dotfiles}/home/.config/.prettierrc.js";
      };
    };

    keyboard = {
      layout = "us";
      variant = "workman";
    };
  };

  programs = {
    git = {
      enable = true;

      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";

      ignores = [
        ".DS_Store"
      ];

      signing = {
        signByDefault = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2YSc/BayEsyCgPLWQZ17/WElA5UI5bChLzMHeXYCXb";
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
      extraConfig = builtins.readFile "${dotfiles}/home/.config/tmux/tmux.conf";
    };

    # firefox = {
    #   enable = true;
    #   profiles = {
    #     "???" = {
    #       search.engines = { };
    #     };
    #   };
    # };
  };

  editorconfig = {
    enable = true;

    settings = {
      "*" = {
        indent_style = "space";
        indent_size = 2;
        # We recommend you to keep these unchanged
        end_of_line = "lf";
        charset = "utf-8";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
      };
      "*.md" = {
        trim_trailing_whitespace = false;
        indent_size = 4;
      };
      "Makefile" = {
        indent_style = "tab";
      };
    };
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = {
      # keybindings = { };
      search = "DuckDuckGo";

      defaults = {
        "com.apple.finder" = {
          # When performing a search, search the current folder by default
          FXDefaultSearchScope = "SCcf";
        };

        "com.spotify.client".AutoStartSettingIsHidden = 0;
      };
    };
  };

  # TODO: only run this on darwin
  home.activation.zActivateSettings = ''
    $DRY_RUN_CMD /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD killall Dock
  '';

  # TODO: only run this on darwin
  home.activation.setDockApps = ''
    function createTile() {
      echo "<dict>"
      echo "  <key>tile-data</key>"
      echo "  <dict>"
      echo "    <key>file-data</key>"
      echo "    <dict>"
      echo "      <key>_CFURLString</key>"
      echo "      <string>$1</string>"
      echo "      <key>_CFURLStringType</key><integer>0</integer>"
      echo "    </dict>"
      echo "  </dict>"
      echo "</dict>"
    }

    function createDirTile() {
      echo "<dict>"
      echo "  <key>tile-data</key>"
      echo "  <dict>"
      echo "    <key>file-data</key>"
      echo "    <dict>"
      echo "      <key>_CFURLString</key>"
      echo "      <string>$1</string>"
      echo "      <key>_CFURLStringType</key><integer>0</integer>"
      echo "    </dict>"
      echo "    <key>file-type</key>"
      echo "    <integer>$2</integer>"
      echo "    <key>arrangement</key>"
      echo "    <integer>$3</integer>"
      echo "    <key>displayas</key>"
      echo "    <integer>$4</integer>"
      echo "    <key>showas</key>"
      echo "    <integer>$5</integer>"
      echo "  </dict>"
      echo "  <key>tile-type</key>"
      echo "  <string>directory-tile</string>"
      echo "</dict>"
    }

    function setDock() {
      setDockApps
      setDockDirs

      # restart Dock to show updates
      killall Dock
    }

    function setDockApps() {
      # clear dock
      defaults write com.apple.dock persistent-apps -array ""

      # add Firefox
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Firefox.app')"
      # add Apple Music
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Music.app')"
      # add Messages
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Messages.app')"
      # add Signal
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Signal.app')"
      # add Slack
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Slack.app')"
      # add Discord
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Discord.app')"
      # add Mail
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Mail.app')"
      # add Calendar
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Calendar.app')"
      # add Notes
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Notes.app')"
      # add Reminders
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/Reminders.app')"
      # add VS Code
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Visual Studio Code.app')"
      # add Fork
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/Fork.app')"
      # add iTerm
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/Applications/iTerm.app')"
      # add System Settings
      defaults write com.apple.dock persistent-apps -array-add "$(createTile '/System/Applications/System Settings.app')"
    }

    function setDockDirs() {
      # clear dock
      defaults write com.apple.dock persistent-others -array ""

      # /Applications
      defaults write com.apple.dock persistent-others -array-add "$(createDirTile '/Applications/' 1 1 1 2)"
      # ~/Downloads
      defaults write com.apple.dock persistent-others -array-add "$(createDirTile '/Users/'$(whoami)'/Downloads/' 2 1 0 0)"
    }

    PATH="/usr/bin:$PATH" $DRY_RUN_CMD setDock
  '';
}
