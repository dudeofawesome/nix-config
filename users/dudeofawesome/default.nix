{ pkgs
, lib
, dotfiles
, vim-lumen
, fish-node-binpath
, fish-node-version
, fish-shell-integrations
, fish-doa-tide-settings
, ...
}:

{
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
    fish = {
      enable = true;

      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
        {
          name = "autopair.fish";
          src = pkgs.fishPlugins.autopair-fish.src;
        }
        {
          name = "node-binpath";
          src = fish-node-binpath;
        }
        # {
        #   name = "node-version";
        #   src = fish-node-version;
        # }
        {
          name = "fishtape";
          src = pkgs.fishPlugins.fishtape_3.src;
        }
        {
          name = "shell-integrations";
          src = fish-shell-integrations;
        }
        {
          name = "doa-tide-settings";
          src = fish-doa-tide-settings;
        }
      ];

      shellAbbrs = {
        "l" = "ls -lha";
        "lblk" = "lsblk --output NAME,SIZE,RM,FSTYPE,FSUSE%,SERIAL,MOUNTPOINT";
        "k" = "kubectl";
      };

      functions = {
        "_tide_item_gcloud.fish" = builtins.readFile "${dotfiles}/home/.config/fish/functions/_tide_item_gcloud.fish";
      };
    };

    atuin = {
      enable = true;

      enableFishIntegration = true;
      enableBashIntegration = true;

      settings = {
        sync_address = "https://atuin.orleans.io";
        style = "compact";
        # word_jump_mode = "subl";
      };
    };

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

    vim = {
      enable = true;

      defaultEditor = true;
      extraConfig = builtins.readFile "${dotfiles}/home/.vim/vimrc";
      plugins = with pkgs.vimPlugins; [
        papercolor-theme
        vim-airline
        dash-vim
        nerdtree
        rainbow
        vim-prettier
        editorconfig-vim
        vim-lumen
      ];
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
    # TODO: convince editorconfig.settings to accept a string, or write an ini-to-set parser
    # settings = builtins.readFile "${dotfiles}/home/.editorconfig";
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = {
      # keybindings = { };
      search = "DuckDuckGo";
    };
  };
}
