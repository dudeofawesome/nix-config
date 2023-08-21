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
  };
}
