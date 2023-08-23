{ pkgs
, lib
, osConfig
, dotfiles
, ...
}:
{
  imports = [
    ./shells.nix
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

    vim = {
      enable = true;
      packageConfigurable = pkgs.vim-full;

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
    };
  };
}
