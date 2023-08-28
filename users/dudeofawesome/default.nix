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
      finicky = {
        target = ".config/finicky.js";
        source = "${dotfiles}/settings/.finicky.js";
      };
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
      echo "    <key>arrangement</key>"
      echo "    <integer>$6</integer>"
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
      defaults write com.apple.dock persistent-others -array-add "$(createDirTile '/Applications/' 1 1 1 2 1)"
      # ~/Downloads
      defaults write com.apple.dock persistent-others -array-add "$(createDirTile '/Users/'$(whoami)'/Downloads/' 2 1 0 1 2)"
    }

    PATH="/usr/bin:$PATH" $DRY_RUN_CMD setDock
  '';

  # TODO: only run this on darwin
  home.activation.setFinickyConfigLoc = ''
    # set Finicky's config location here, instead of above because home-manager doesn't support plist's type "data"
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD defaults write net.kassett.finicky config_location_bookmark -data 626F6F6BE8040000000004103000000000000000000000000000000000000000000000000000000000000000000000000804000003000000010100006E697800050000000101000073746F7265000000270000000101000061666C786779367638336A6D69697678763570796A6B6C31326368386B3870302D736F7572636500080000000101000073657474696E67730B000000010100002E66696E69636B792E6A73001400000001060000040000001000000020000000500000006000000008000000040300000200000000000000080000000403000021000000000000000800000004030000079C0C00000000000800000004030000239C0C00000000000800000004030000AFA60C0000000000140000000106000090000000A0000000B0000000C0000000D00000000800000000040000C1CD27E43F800000180000000102000001000000000000000F0000000000000000000000000000000C0000000109000066696C653A2F2F2F6E69782F09000000010100004E69782053746F726500000008000000040300000050A11B73000000080000000004000041C54424D0823224240000000101000046424642384633372D443038442D344442392D423044302D34423334353641373637354318000000010200008500000001000000EF13000001000000000000000000000004000000010100002F6E6978080000000109000066696C653A2F2F2F0C000000010100004D6163696E746F7368204844080000000004000041C52EA85B000000240000000101000036453335423742382D313343422D343942422D383735342D41384241463630344145464418000000010200008100000001000000EF13000001000000000000000000000001000000010100002F00000060000000FEFFFFFF00F000000000000007000000022000004C0200000000000005200000CC0100000000000010200000DC0100000000000011200000000200000000000012200000540100000000000013200000F001000000000000202000002C02000000000000040000000303000000F000000400000003030000010000000400000003030000000000001800000001060000C0020000CC020000D8020000D8020000D8020000D8020000F900000001020000626538393237353633353033313164366437323437636130656535623132643037626135393766623235323735656263356530373462363733346363663062383B30303B30303030303030303B30303030303030303B30303030303030303B303030303030303030303030303032303B636F6D2E6170706C652E6170702D73616E64626F782E726561642D77726974653B30313B30313030303030663B303030303030303030303063396332343B30313B2F6E69782F73746F72652F61666C786779367638336A6D69697678763570796A6B6C31326368386B3870302D736F757263652F73657474696E67732F2E66696E69636B792E6A7300000000A8000000FEFFFFFF01000000580200000D00000004100000740000000000000005100000E000000000000000101000000C0100000000000040100000FC0000000000000000200000E40200000000000002200000C001000000000000052000002C0100000000000010200000400100000000000011200000740100000000000012200000540100000000000013200000640100000000000020200000A00100000000000080F000000403000000000000
  '';
}
