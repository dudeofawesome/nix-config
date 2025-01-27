{
  pkgs,
  pkgs-unstable,
  lib,
  machine-class,
  config,
  ...
}:
with lib;
{
  home.packages = with pkgs-unstable; [
    rubyPackages.solargraph
    gitlab-ci-ls
  ];

  programs.vscode = {
    enable = lib.mkDefault (machine-class == "pc");

    mutableUserSettings = ./vscode-settings.json;

    extensions =
      let
        nix4vscode = (import ./extensions.nix) { inherit pkgs lib; };
      in
      # prefer nixpkgs extensions
      with pkgs-unstable.vscode-extensions;
      # fallback to nix4vscode
      with nix4vscode;
      [
        alefragnani.bookmarks
        alesbrelih.gitlab-ci-ls
        antyos.openscad
        beardedbear.beardedtheme
        bierner.markdown-mermaid
        blueglassblock.better-json5
        bmalehorn.vscode-fish
        bpruitt-goddard.mermaid-markdown-syntax-highlighting
        # bradlc.vscode-tailwindcss
        bruno-api-client.bruno
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
        eeyore.yapf
        effectful-tech.effect-vscode
        equinusocio.vsc-material-theme-icons
        esbenp.prettier-vscode
        fabiospampinato.vscode-diff
        firefox-devtools.vscode-firefox-debug
        flesler.url-encode
        fwcd.kotlin
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
        mathiasfrohlich.kotlin
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
        ms-vsliveshare.vsliveshare
        msjsdiag.vscode-react-native
        mxsdev.typescript-explorer
        naumovs.color-highlight
        novy.vsc-gcode
        orta.vscode-jest
        oven.bun-vscode
        pkief.material-icon-theme
        pkief.material-product-icons
        shopify.ruby-lsp
        redhat.ansible
        pkgs-unstable.vscode-extensions.redhat.vscode-yaml
        ryu1kn.partial-diff
        seeker-dk.node-modules-viewer
        semanticdiff.semanticdiff
        shd101wyy.markdown-preview-enhanced
        shopify.ruby-lsp
        signageos.signageos-vscode-sops
        streetsidesoftware.code-spell-checker
        stylelint.vscode-stylelint
        tamasfe.even-better-toml
        tomoki1207.pdf
        tomoyukim.vscode-mermaid-editor
        tyriar.lorem-ipsum
        ultram4rine.vscode-choosealicense
        visualstudioexptteam.intellicode-api-usage-examples
        visualstudioexptteam.vscodeintellicode
        vitest.explorer
        wallabyjs.quokka-vscode
        weaveworks.vscode-gitops-tools
        wmaurer.change-case
        yoavbls.pretty-ts-errors
        yzhang.markdown-all-in-one

        # angular.ng-template
        # dineug.vuerd-vscode
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
  };
}
