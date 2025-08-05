{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:
{
  home.packages = with pkgs-unstable; [
    python3
    python3Packages.ipykernel
    python3Packages.jupyterlab
    python3Packages.pyzmq # Adding pyzmq explicitly
    python3Packages.venvShellHook
    python3Packages.pip
    python3Packages.numpy
    python3Packages.pandas
    python3Packages.requests

    rubyPackages.prettier_print
    rubyPackages.syntax_tree
    rubyPackages.syntax_tree-haml
    rubyPackages.syntax_tree-rbs
  ];

  programs = {
    vscode = {
      package = pkgs-unstable.vscode;

      mutableExtensionsDir = lib.mkDefault false;

      profiles.default = {
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
            {
              key = "cmd+f";
              command = "-list.find";
              when = "listFocus && listSupportsFind";
            }
            {
              key = "cmd+f";
              command = "list.find";
              when = "!filesExplorerFocus && listFocus && listSupportsFind";
            }
            {
              key = "cmd+/";
              command = "-toggleExplainMode";
              when = "suggestWidgetVisible";
            }
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
            {
              key = "cmd+k left";
              command = "workbench.action.moveEditorToLeftGroup";
            }
            {
              key = "cmd+k down";
              command = "workbench.action.moveEditorToBelowGroup";
            }
            {
              key = "cmd+k up";
              command = "workbench.action.moveEditorToAboveGroup";
            }
            {
              key = "cmd+k right";
              command = "workbench.action.moveEditorToRightGroup";
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
              command = "runCommands";
              args.commands = [
                "workbench.action.zoomReset"
                "editor.action.fontZoomReset"
              ];
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
              key = "shift+delete";
              command = "deleteRight";
              when = "textInputFocus";
            }

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

            {
              key = "F3";
              command = "-editor.action.nextMatchFindAction";
            }
            {
              key = "F3";
              command = "-workbench.action.terminal.findNext";
            }
            {
              key = "F3";
              command = "-list.find";
            }

            {
              key = "F1";
              command = "-workbench.action.showCommands";
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
      };
    };
  };
}
