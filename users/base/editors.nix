{ pkgs, lib, osConfig, dudeofawesome_dotfiles, nix-vscode-extensions, ... }: {
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

  programs = {
    vscode = {
      mutableExtensionsDir = true;

      keybindings = lib.concatLists [
        # misc
        [
          {
            key = "ctrl+c";
            command = "editor.action.clipboardCopyAction";
            when = "textInputFocus";
          }
          {
            key = "cmd+down";
            command = "list.select";
            when = "listFocus";
          }
          {
            key = "up";
            command = "-showPrevParameterHint";
          }
          {
            key = "down";
            command = "-showNextParameterHint";
          }
          # {
          #   key = "up";
          #   command = "-selectPrevSuggestion";
          # }
          # {
          #   key = "down";
          #   command = "-selectNextSuggestion";
          # }
        ]
        # tab control
        [
          {
            key = "cmd+\\";
            command = "workbench.action.toggleSidebarVisibility";
          }
          {
            key = "cmd+b";
            command = "workbench.action.splitEditor";
          }
          {
            key = "ctrl+tab";
            command = "workbench.action.nextEditor";
          }
          {
            key = "ctrl+shift+tab";
            command = "workbench.action.previousEditor";
          }

          {
            key = "cmd+k cmd+s";
            command = "workbench.action.files.saveAll";
          }
          {
            key = "alt+cmd+s";
            command = "-workbench.action.files.saveAll";
          }

          {
            key = "cmd+,";
            command = "workbench.action.openSettingsJson";
          }
          {
            key = "cmd+shift+,";
            command = "workbench.action.openWorkspaceSettingsFile";
          }
        ]
        # terminal control
        [
          {
            key = "cmd+shift+c";
            command = "workbench.action.terminal.toggleTerminal";
          }
          {
            key = "alt+cmd+m";
            command = "workbench.action.toggleMaximizedPanel";
          }
          {
            key = "cmd+alt+left";
            command = "workbench.action.terminal.focusPrevious";
            when = "terminalFocus";
          }
          {
            key = "cmd+alt+right";
            command = "workbench.action.terminal.focusNext";
            when = "terminalFocus";
          }
          {
            key = "cmd+t";
            command = "workbench.action.terminal.new";
            when = "terminalFocus";
          }
        ]
        # zoom control
        [
          {
            key = "cmd+=";
            when = "editorTextFocus";
            command = "editor.action.fontZoomIn";
          }
          {
            key = "cmd+-";
            when = "editorTextFocus";
            command = "editor.action.fontZoomOut";
          }
          {
            key = "cmd+0";
            command = "workbench.action.zoomReset";
          }
          {
            key = "cmd+0";
            command = "editor.action.fontZoomReset";
          }

          {
            key = "cmd+=";
            command = "-workbench.action.zoomIn";
          }
          {
            key = "cmd+-";
            command = "-workbench.action.zoomOut";
          }
          {
            key = "cmd+numpad0";
            command = "-workbench.action.zoomReset";
          }
        ]
        # text control
        [
          {
            key = "ctrl+cmd+up";
            command = "editor.action.moveLinesUpAction";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "ctrl+cmd+down";
            command = "editor.action.moveLinesDownAction";
            when = "editorTextFocus && !editorReadonly";
          }

          {
            key = "cmd+alt+/";
            command = "editor.action.blockComment";
            when = "editorTextFocus && !editorReadonly";
          }
        ]
        # text case transform
        [
          {
            key = "cmd+k cmd+u";
            command = "editor.action.transformToUppercase";
            when = "editorTextFocus && !editorReadonly";
          }
          {
            key = "cmd+k cmd+l";
            command = "editor.action.transformToLowercase";
            when = "editorTextFocus && !editorReadonly";
          }

          {
            key = "cmd+k cmd+u";
            command = "-editor.action.removeCommentLine";
          }
          {
            key = "cmd+k cmd+l";
            command = "-editor.toggleFold";
          }
        ]
      ];

      # TODO: make this file mutable
      #   https://github.com/andyrichardson/dotfiles/blob/28c3630e71d65d92b88cf83b2f91121432be0068/nix/home/vscode.nix#L5
      #   https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
      # userSettings = lib.importJSON "${pkgs.runCommand "remove-comments"
      #   { input = builtins.readFile ./vscode-settings.json; }
      #   ''
      #     mkdir "$out"
      #     echo "$input" | sed 's/\/\/ .*$//g' > "$out/message"
      #   ''}/message";
    };

    vim = {
      enable = true;
      packageConfigurable = pkgs.vim-full;

      defaultEditor = true;
      extraConfig = builtins.readFile "${dudeofawesome_dotfiles}/home/.vim/vimrc";
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

  home.activation.createVSCodeIntellicodeDir = ''
    path="/var/lib/vsintellicode/"
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD sudo mkdir -p "$path"
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD sudo chown $(whoami) "$path"
  '';
}