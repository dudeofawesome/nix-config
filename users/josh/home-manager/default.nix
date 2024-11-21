{ pkgs, lib, machine-class, ... }:
{
  imports = [
    ../../../modules/defaults/home-manager
    ../../../modules/defaults/home-manager/finicky
    ../../dudeofawesome/home-manager/browsers.nix

    ./shells.nix
  ];

  home = {
    # It is occasionally necessary for Home Manager to change configuration
    # defaults in a way that is incompatible with stateful data. This could, for
    # example, include switching the default data format or location of a file.
    #
    # The state version indicates which default settings are in effect and will
    # therefore help avoid breaking program configurations. Switching to a
    # higher state version typically requires performing some manual steps,
    # such as data conversion or moving files.
    stateVersion = "23.05"; # Did you read the comment?

    packages = with pkgs; [
      (if (machine-class == "pc") then _1password-cli else { })
    ];

    keyboard = {
      layout = "us";
      variant = "dvorak";
    };
  };

  programs = {
    ssh = {
      matchBlocks = {
        "sftp-aws.paciolan.info" = {
          user = "pacsftp-shift4";
          identityFile = "~/.ssh/sftp-aws.paciolan.com_rsa";
        };
        "files.shift4.com" = {
          user = "joshuagibbs";
          identityFile = "~/.ssh/files.shift4.com_rsa";
        };

        "gibbs.tk".user = "upaymeifixit";
        "Joshs-Notebook.local".user = "Josh";
        "home.powell.place".user = "josh";
        "router" = {
          user = "root";
          hostname = "10.0.0.1";
        };
        "terracompute" = {
          user = "vast";
          hostname = "192.168.4.225";
        };
        "soto-server" = {
          user = "josh";
          hostname = "10.0.15.144";
        };
      };
    };

    git = {
      userName = "Josh Gibbs";
      userEmail = "josh@gibbs.tk";

      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICWpH2swLUhFYS8ffRP7bviAwTroqaCACeAcp6kAtyO0";
    };

    dock = {
      enable = true;

      apps = [
        "/Applications/Google Chrome.app"
        "/Applications/Spotify.app"
        "/Applications/Microsoft Outlook.app"
        "/Applications/zoom.us.app"
        "/Applications/Slack.app"
        "/Applications/Messenger.app"
        "/Applications/Signal.app"
        "/Applications/Discord.app"
        "/Applications/Sublime Text.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/TablePlus.app"
        "/Applications/iTerm.app"
        "/Applications/Fork.app"
        "/Applications/Postman.app"
        "/Applications/Todoist.app"
        "/System/Applications/Stickies.app"
      ];

      others = {
        # ~/Downloads
        "/Users/'$(whoami)'/Downloads/" = {
          fileType = "2";
          arrangement = "1";
          displayAs = "0";
          showAs = "1";
          arrangement2 = "2";
        };
      };
    };
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
      search = "Google";

      defaults = {
        "com.apple.dock" = {
          minimize-to-application = false;
        };

        "com.apple.finder" = {
          AppleShowAllFiles = false;
        };
      };
    };
  };

  xdg.configFile.finicky.source = ./finicky.js;
}
