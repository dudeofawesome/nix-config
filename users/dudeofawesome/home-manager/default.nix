{
  pkgs,
  pkgs-unstable,
  lib,
  osConfig,
  config,
  machine-class,
  os,
  ...
}:
let
  doa-lib = import ../../../lib;
  pkg-installed = doa-lib.pkg-installed {
    inherit osConfig;
    homeConfig = config;
  };
  has_docker = pkg-installed pkgs.docker;
in
{
  imports = [
    ../../../modules/presets/home-manager/paciolan.nix

    ../../../modules/defaults/home-manager
    ../../../modules/defaults/home-manager/aerospace.nix
    ../../../modules/defaults/home-manager/1password-gui.nix
    ../../../modules/defaults/home-manager/docker-desktop.nix
    ../../../modules/defaults/home-manager/finicky
    ../../../modules/defaults/home-manager/fork.nix
    ../../../modules/defaults/home-manager/gnome.nix
    ../../../modules/defaults/home-manager/gitup.nix
    ../../../modules/defaults/home-manager/google-earth-pro.nix
    ../../../modules/defaults/home-manager/hammerspoon
    ../../../modules/defaults/home-manager/ice.nix
    ../../../modules/defaults/home-manager/middleclick.nix
    ../../../modules/defaults/home-manager/postico.nix
    ../../../modules/defaults/home-manager/typora.nix
    ../../../modules/defaults/home-manager/wezterm

    ./browsers.nix
    ./vscode.nix
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

    packages =
      with pkgs;
      [
        act
        awscli2
        pkgs-unstable.d2
        eternal-terminal
        krew
        watchman
      ]
      ++ (
        if (machine-class == "pc") then
          [
            # https://github.com/NixOS/nixpkgs/issues/254944
            # TODO: investigate using an activation script to copy the .app to /Applications
            # _1password-gui
            pkgs-unstable._1password-cli
            pkgs-unstable.bruno
            cyberduck
            pkgs-unstable.discord
            drawio
            inkscape
            losslesscut-bin
            opentofu
            pkgs-unstable.raycast
            pkgs-unstable.rectangle
            pkgs-unstable.signal-desktop
            pkgs-unstable.spotify
            pkgs-unstable.tableplus
            pkgs-unstable.tailscale
          ]
          ++ (if (os == "linux") then cider else [ ])
        else
          [ ]
      )
      ++ (if (has_docker) then [ dive ] else [ ]);

    keyboard = {
      layout = "us";
      variant = "workman";
    };
  };

  # sops.secrets."hosts/nixos/monongahela/ssh-keys/dudeofawesome_nix-config/private" = {
  #   format = "yaml";
  #   sopsFile = ../../../hosts/nixos/monongahela/secrets.yaml;
  #   # path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  programs = {
    ssh.matchBlocks =
      let
        hostUnreachable = (host: ''host ${host} !exec "ping -c1 -q -t1 '%h' 2> /dev/null"'');
      in
      {
        "unifi".user = "root";
        "unifi-remote" = {
          match = hostUnreachable "unifi";
          hostname = "oc.orleans.io";
        };
        "monongahela".user = "dudeofawesome";
        "monongahela-remote" = {
          match = hostUnreachable "monongahela";
          proxyJump = "oc.orleans.io";
        };
        "haleakala" = {
          user = "dudeofawesome";
          hostname = "192.168.254.49";
        };
        "steamdeck".user = "deck";

        "badlands-vm".user = "dudeofawesome";

        "home.powell.place".user = "louis";

        "home.saldivar.io" = {
          user = "edgar";
          port = 69;
        };
        "terracompute" = {
          hostname = "192.168.4.225";
          user = "vast";
        };
        "terracompute-remote" = {
          match = hostUnreachable "192.168.4.225";
          proxyJump = "home.saldivar.io";
        };
      };

    git = {
      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";

      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD3VYzXLFPEC25hK7o5+NrV9cvNlyV7Y93UyAQospbw";

      includes = [
        {
          condition = "gitdir:~/git/paciolan/";
          contents = {
            user = {
              email = "lorleans@paciolan.com";
            };
          };
        }
      ];
    };

    dock = {
      enable = true;

      apps = [
        "/Applications/Firefox.app"
        "/System/Applications/Music.app"
        "/System/Applications/Messages.app"
        "${pkgs-unstable.signal-desktop}/Applications/Signal.app"
        "${pkgs-unstable.slack}/Applications/Slack.app"
        "${pkgs-unstable.discord}/Applications/Discord.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Notes.app"
        "/System/Applications/Reminders.app"
        "${pkgs-unstable.vscode}/Applications/Visual Studio Code.app"
        "/Applications/Fork.app"
        "${pkgs-unstable.wezterm}/Applications/WezTerm.app"
        "/System/Applications/System Settings.app"
      ];
    };

    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        cachix
        gh
        glab
      ];
    };

    awscli = {
      enable = true;
      settings =
        let
          op_aws = "${config.home.homeDirectory}/${config.home.file._1password-awscli.target}";
        in
        {
          default = {
            region = "us-west-2";
            output = "yaml-stream";
            credential_process = "${op_aws} 'rlfhru5fnw3crzq6be4dsx3qfu' 'Paciolan'";
            cli_pager = "${pkgs.moar}/bin/moar --lang=yaml";
          };

          "profile api1" = {
            region = "us-west-2";
            credential_process = "${op_aws} 'vaw35vurdty442jpy3npbm6osi' 'Paciolan (Shared)'";
          };

          "profile srd" = {
            region = "us-west-2";
            credential_process = "${op_aws} 'v6viem5ekz2v66eu5snwpyjtaq' 'Paciolan (Shared)'";
          };

          "profile prod-readonly" = {
            source_profile = "default";
            region = "us-west-1";
            role_arn = "arn:aws:iam::046314659632:role/AssumeRole-Dev-ReadOnly";
          };
        };
    };
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
      search = "DuckDuckGo";
    };
  };
}
