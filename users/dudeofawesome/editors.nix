{ pkgs, lib, osConfig, dotfiles, nix-vscode-extensions, ... }: {
  home.packages = with pkgs; [
    rubyPackages.solargraph
  ];

  programs = {
    vscode = {
      enable = true;

      mutableExtensionsDir = true;
      extensions = with nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        alefragnani.bookmarks
        antyos.openscad
        bmalehorn.vscode-fish
        bradlc.vscode-tailwindcss
        castwide.solargraph
        codezombiech.gitignore
        coolbear.systemd-unit-file
        dart-code.dart-code
        dart-code.flutter
        dbaeumer.vscode-eslint
        deerawan.vscode-dash
        donjayamanne.githistory
        drknoxy.eslint-disable-snippets
        eamodio.gitlens
        editorconfig.editorconfig
        equinusocio.vsc-community-material-theme
        esbenp.prettier-vscode
        fabiospampinato.vscode-diff
        firefox-devtools.vscode-firefox-debug
        flesler.url-encode
        github.vscode-github-actions
        github.vscode-pull-request-github
        gitlab.gitlab-workflow
        golang.go
        gracefulpotato.rbs-syntax
        graphql.vscode-graphql
        graphql.vscode-graphql-execution
        gruntfuggly.todo-tree
        hashicorp.terraform
        inferrinizzard.prettier-sql-vscode
        jnoortheen.nix-ide
        mikestead.dotenv
        mrmlnc.vscode-scss
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-vscode-remote.remote-wsl
        ms-vscode.hexeditor
        ms-vscode.remote-explorer
        # ms-vscode.sublime-keybindings # TODO: do I need this?
        ms-vsliveshare.vsliveshare
        naumovs.color-highlight
        novy.vsc-gcode
        orta.vscode-jest
        pkief.material-icon-theme
        pkief.material-product-icons
        shopify.ruby-lsp
        redhat.ansible
        redhat.vscode-yaml
        ryu1kn.partial-diff
        seeker-dk.node-modules-viewer
        shd101wyy.markdown-preview-enhanced
        streetsidesoftware.code-spell-checker
        stylelint.vscode-stylelint
        tamasfe.even-better-toml
        tomoki1207.pdf
        tusaeff.vscode-iterm2-theme-sync
        tyriar.lorem-ipsum
        ultram4rine.vscode-choosealicense
        visualstudioexptteam.intellicode-api-usage-examples
        visualstudioexptteam.vscodeintellicode
        wallabyjs.quokka-vscode
        weaveworks.vscode-gitops-tools
        wingrunr21.vscode-ruby
        wmaurer.change-case
        yzhang.markdown-all-in-one
      ];

      keybindings = [
        {
          key = "ctrl+c";
          command = "editor.action.clipboardCopyAction";
          when = "textInputFocus";
        }
        {
          key = "cmd+,";
          command = "workbench.action.openSettingsJson";
        }
        {
          key = "cmd+shift+,";
          command = "workbench.action.openWorkspaceSettingsFile";
        }
        {
          key = "ctrl+cmd+up";
          command = "editor.action.moveLinesUpAction";
          when = "editorTextFocus";
        }
        {
          key = "ctrl+cmd+down";
          command = "editor.action.moveLinesDownAction";
          when = "editorTextFocus";
        }
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
          key = "cmd+down";
          command = "list.select";
          when = "listFocus";
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
          key = "cmd+numpad0";
          command = "-workbench.action.zoomReset";
        }
      ];

      userSettings = lib.importJSON "${pkgs.runCommand "remove-comments"
        { input = builtins.readFile ./vscode-settings.json; }
        ''
          mkdir "$out"
          echo "$input" | sed 's/\/\/ .*$//g' > "$out/message"
        ''}/message";
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
  };
}
