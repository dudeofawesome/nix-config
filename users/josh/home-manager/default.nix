{
  pkgs,
  pkgs-unstable,
  lib,
  machine-class,
  config,
  ...
}:
{
  imports = lib.flatten [
    (lib.optional (machine-class == "pc") ../../../modules/presets/home-manager/paciolan.nix)

    ../../../modules/defaults/home-manager
    ../../../modules/defaults/home-manager/aerospace.nix
    ../../../modules/defaults/home-manager/1password-gui.nix
    ../../../modules/defaults/home-manager/docker-desktop.nix
    ../../../modules/defaults/home-manager/finicky
    ../../../modules/defaults/home-manager/fork.nix
    ../../../modules/defaults/home-manager/gnome.nix
    ../../../modules/defaults/home-manager/gitup.nix
    ../../../modules/defaults/home-manager/google-earth-pro.nix
    ../../../modules/defaults/home-manager/ice.nix
    ../../../modules/defaults/home-manager/moonlight.nix
    ../../../modules/defaults/home-manager/postico.nix
    ../../../modules/defaults/home-manager/wezterm

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

    packages = with pkgs-unstable; [
      gitlab-ci-ls
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

      includes = [
        {
          condition = "gitdir:~/git/Paciolan/";
          contents = {
            user = {
              email = "joshuagibbs@paciolan.com";
            };
          };
        }
      ];
    };

    _1password-cli = {
      enable = machine-class == "pc";
      package = pkgs-unstable._1password-cli;
    };
    _1password-gui = {
      enable = machine-class == "pc";
      package = pkgs-unstable._1password-gui;
      extraConfig."keybinds.quickAccess" = "Shift+CommandOrControl+Space";
    };

    # I'm using brew instead due to permission and deep linking issues when installed via nix
    zoom-us.enable = false;

    dock = {
      enable = true;

      apps = lib.flatten [
        "/Applications/Google Chrome.app"
        "/Applications/Spotify.app"
        "${config.home.homeDirectory}/Applications/Chrome Apps.localized/Gmail.app"
        "/Applications/Microsoft Outlook.app"
        "/Applications/zoom.us.app"
        (lib.optional config.programs.slack.enable "${config.programs.slack.package}/Applications/Slack.app")
        "/Applications/Messenger.app"
        "/Applications/Signal.app"
        "/System/Applications/Messages.app"
        "/Applications/Discord.app"
        "/Applications/Visual Studio Code.app"
        "${pkgs.tableplus}/Applications/TablePlus.app"
        "/Applications/Fork.app"
        "${pkgs.postman}/Applications/Postman.app"
        "/Applications/Todoist.app"
        "/System/Applications/Notes.app"
        "/System/Applications/iPhone Mirroring.app"
      ];

      others = {
        # ~/Downloads
        "${config.home.homeDirectory}/Downloads/" = {
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

  programs.finicky = {
    enable = true;
    settings = builtins.readFile ./finicky.js;
  };
}
