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
    gitlab-ci-ls
    rubyPackages.solargraph
  ];

  programs.vscode = {
    enable = lib.mkDefault (machine-class == "pc");

    mutableUserSettings = ./vscode-settings.json;

    profiles.default = {
      extensions =
        let
          nix4vscode = (import ./extensions.nix) { inherit pkgs lib; };

          claude-code = pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "claude-code";
            publisher = "anthropic";
            version = config.programs.claude-code.package.version;
            sha256 = "ic7GcsVcmy1pbiqn5mzdoak9sUqHTCotjOjw7NVfsjQ=";

            postInstall = ''
              mkdir -p "$out/$installPrefix/resources/native-binary"
              rm -f "$out/$installPrefix/resources/native-binary/claude"*
              ln -s "${config.programs.claude-code.package}/bin/claude" "$out/$installPrefix/resources/native-binary/claude"
            '';
          };
        in
        # fallback to nixpkgs
        with pkgs-unstable.vscode-extensions;
        [
          alefragnani.bookmarks
          nix4vscode.alesbrelih.gitlab-ci-ls
          claude-code
          antyos.openscad
          nix4vscode.beardedbear.beardedtheme
          bierner.markdown-mermaid
          nix4vscode.blueglassblock.better-json5
          bmalehorn.vscode-fish
          nix4vscode.bpruitt-goddard.mermaid-markdown-syntax-highlighting
          # nix4vscode.bradlc.vscode-tailwindcss
          nix4vscode.bruno-api-client.bruno
          castwide.solargraph
          codezombiech.gitignore
          # nix4vscode.connor4312.nodejs-testing
          coolbear.systemd-unit-file
          dart-code.dart-code
          dart-code.flutter
          dbaeumer.vscode-eslint
          nix4vscode.deerawan.vscode-dash
          donjayamanne.githistory
          nix4vscode.drknoxy.eslint-disable-snippets
          eamodio.gitlens
          editorconfig.editorconfig
          nix4vscode.eeyore.yapf
          nix4vscode.effectful-tech.effect-vscode
          esbenp.prettier-vscode
          nix4vscode.fabiospampinato.vscode-diff
          firefox-devtools.vscode-firefox-debug
          nix4vscode.flesler.url-encode
          nix4vscode.fwcd.kotlin
          nix4vscode.ghmcadams.lintlens
          nix4vscode.github.vscode-github-actions
          nix4vscode.github.vscode-pull-request-github
          nix4vscode.gitlab.gitlab-workflow
          golang.go
          nix4vscode.gracefulpotato.rbs-syntax
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          nix4vscode.graphql.vscode-graphql-execution
          gruntfuggly.todo-tree
          hashicorp.terraform
          nix4vscode.idleberg.applescript
          nix4vscode.inferrinizzard.prettier-sql-vscode
          jebbs.plantuml
          jnoortheen.nix-ide
          mads-hartmann.bash-ide-vscode
          mathiasfrohlich.kotlin
          nix4vscode.mermaidchart.vscode-mermaid-chart
          mikestead.dotenv
          nix4vscode.mrmlnc.vscode-scss
          ms-azuretools.vscode-docker
          nix4vscode.ms-kubernetes-tools.vscode-kubernetes-tools
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode-remote.remote-wsl
          ms-vscode.hexeditor
          ms-vscode.remote-explorer
          ms-vsliveshare.vsliveshare
          nix4vscode.msjsdiag.vscode-react-native
          nix4vscode.mxsdev.typescript-explorer
          naumovs.color-highlight
          nix4vscode.novy.vsc-gcode
          nix4vscode.orta.vscode-jest
          nix4vscode.oven.bun-vscode
          nix4vscode.openai.chatgpt
          pkief.material-icon-theme
          pkief.material-product-icons
          shopify.ruby-lsp
          redhat.ansible
          redhat.java
          redhat.vscode-yaml
          rust-lang.rust-analyzer
          ryu1kn.partial-diff
          nix4vscode.seeker-dk.node-modules-viewer
          nix4vscode.semanticdiff.semanticdiff
          shopify.ruby-lsp
          # signageos.signageos-vscode-sops
          streetsidesoftware.code-spell-checker
          stylelint.vscode-stylelint
          tamasfe.even-better-toml
          nix4vscode.terrastruct.d2
          tomoki1207.pdf
          nix4vscode.tomoyukim.vscode-mermaid-editor
          nix4vscode.tyriar.lorem-ipsum
          nix4vscode.ultram4rine.vscode-choosealicense
          visualstudioexptteam.intellicode-api-usage-examples
          visualstudioexptteam.vscodeintellicode
          nix4vscode.vitest.explorer
          nix4vscode.vstirbu.vscode-mermaid-preview
          nix4vscode.weaveworks.vscode-gitops-tools
          wmaurer.change-case
          yoavbls.pretty-ts-errors
          nix4vscode.yutengjing.open-in-external-app
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
  };
}
