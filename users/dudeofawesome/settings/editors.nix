{ pkgs, lib, config, nix-vscode-extensions, ... }:
let
  userDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else
      "${config.xdg.configHome}/Code/User";
  configFilePath = "${userDir}/settings.json";
in
{
  home.packages = with pkgs; [
    rubyPackages.solargraph
  ];

  # home.file.vscode_settings = {
  #   target = configFilePath;
  #   source = config.lib.file.mkOutOfStoreSymlink ./vscode-settings.json;
  # };
  home.activation.createMutableVSCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp -f "${./vscode-settings.json}" ~/"${configFilePath}"
  '';

  programs = {
    vscode = {
      enable = true;

      extensions = with nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        alefragnani.bookmarks
        antyos.openscad
        bmalehorn.vscode-fish
        bradlc.vscode-tailwindcss
        castwide.solargraph
        codezombiech.gitignore
        connor4312.nodejs-testing
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
        ghmcadams.lintlens
        github.vscode-github-actions
        github.vscode-pull-request-github
        gitlab.gitlab-workflow
        golang.go
        gracefulpotato.rbs-syntax
        graphql.vscode-graphql
        graphql.vscode-graphql-execution
        graphql.vscode-graphql-syntax
        gruntfuggly.todo-tree
        hashicorp.terraform
        idleberg.applescript
        inferrinizzard.prettier-sql-vscode
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
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
        oven.bun-vscode
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
        wmaurer.change-case
        yzhang.markdown-all-in-one

        # angular.ng-template
        # dineug.vuerd-vscode
        # fwcd.kotlin
        # johnpapa.angular2
        # juanblanco.solidity
        # ms-dotnettools.csharp
        # xadillax.viml
        # leetcode.vscode-leetcode
        # wangtao0101.debug-leetcode
        # vsciot-vscode.vscode-arduino
        # vinnyjames.vscode-autohotkey-vj
        # zero-plusplus.vscode-autohotkey-debug
        # trixnz.vscode-lua
        # actboy168.lua-debug

        # grapecity.gc-excelviewer
        # johnpapa.vscode-peacock
        # jumpinjackie.vscode-map-preview
        # jsayol.firebase-explorer
      ];

      # TODO: make this file mutable
      #   https://github.com/andyrichardson/dotfiles/blob/28c3630e71d65d92b88cf83b2f91121432be0068/nix/home/vscode.nix#L5
      #   https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
      #   https://github.com/nix-community/home-manager/pull/2743/files
      # userSettings = lib.importJSON "${pkgs.runCommand "remove-comments"
      #   { input = builtins.readFile ./vscode-settings.json; }
      #   ''
      #     mkdir "$out"
      #     echo "$input" \
      #       | sed 's/\/\/ .*$//g' \
      #       > "$out/message"
      #   ''}/message";
    };
  };
}
