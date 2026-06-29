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
    lldb
  ];

  programs.vscode = {
    enable = lib.mkDefault (machine-class == "pc");

    mutableUserSettings = ./vscode-settings.json;

    profiles.default = {
      extensions =
        let
          nix4vscodeExtensions = pkgs-unstable.nix4vscode.forVscode [
            "alesbrelih.gitlab-ci-ls"
            "beardedbear.beardedtheme"
            "blueglassblock.better-json5"
            "bpruitt-goddard.mermaid-markdown-syntax-highlighting"
            # "bradlc.vscode-tailwindcss"
            "bruno-api-client.bruno"
            "charliermarsh.ruff"
            # "connor4312.nodejs-testing"
            "deerawan.vscode-dash"
            "drknoxy.eslint-disable-snippets"
            "eeyore.yapf"
            "effectful-tech.effect-vscode"
            "ezoosk.claude-context-bar"
            "fabiospampinato.vscode-diff"
            "flesler.url-encode"
            "fwcd.kotlin"
            "ghmcadams.lintlens"
            "github.vscode-github-actions"
            "github.vscode-pull-request-github"
            "gitlab.gitlab-workflow"
            "gracefulpotato.rbs-syntax"
            "graphql.vscode-graphql-execution"
            "idleberg.applescript"
            "inferrinizzard.prettier-sql-vscode"
            "leathong.openscad-language-support"
            "mermaidchart.vscode-mermaid-chart"
            "mrmlnc.vscode-scss"
            "ms-kubernetes-tools.vscode-kubernetes-tools"
            "msjsdiag.vscode-react-native"
            "mxsdev.typescript-explorer"
            "novy.vsc-gcode"
            "orta.vscode-jest"
            "oven.bun-vscode"
            "seeker-dk.node-modules-viewer"
            "semanticdiff.semanticdiff"
            "swiftlang.swift-vscode"
            "terrastruct.d2"
            "thijsdaniels.vscode-openscad-preview"
            "tomoyukim.vscode-mermaid-editor"
            "tyriar.lorem-ipsum"
            "ultram4rine.vscode-choosealicense"
            "vitest.explorer"
            "vstirbu.vscode-mermaid-preview"
            "weaveworks.vscode-gitops-tools"
            "yutengjing.open-in-external-app"
          ];

          claude-code = pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "claude-code";
            publisher = "anthropic";
            version = config.programs.claude-code.package.version;
            sha256 = "sha256-443PFzX3FNJnNBtlOrS9sqhFDYyyn9JMwD8IbgtxSl0=";

            postInstall = ''
              mkdir -p "$out/$installPrefix/resources/native-binary"
              rm -f "$out/$installPrefix/resources/native-binary/claude"*
              ln -s "${lib.getExe config.programs.claude-code.package}" "$out/$installPrefix/resources/native-binary/claude"
            '';
          };

          # https://marketplace.visualstudio.com/items?itemName=openai.chatgpt
          codex = pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "chatgpt";
            publisher = "openai";
            version = "26.5623.42026";
            sha256 = "sha256-ZQhX2EoTEGDYHSaQqOuLjMuSOVbo3Gzc8slmRm1iDMA=";

            postInstall = ''
              echo "ENV:"
              env

              case "$system" in
                aarch64-linux)
                  platformString="linux-aarch64"
                  ;;
                aarch64-darwin)
                  platformString="macos-aarch64"
                  ;;
                *)
                  echo "Unsupported system: $system" >&2
                  exit 1
                  ;;
              esac

              mkdir -p "$out/$installPrefix/bin/$platformString/"
              rm -f "$out/$installPrefix/bin/"*/{codex,rg}
              ln -s "${lib.getExe config.programs.codex.package}" "$out/$installPrefix/bin/$platformString/codex"
              ln -s "${lib.getExe config.programs.ripgrep.package}" "$out/$installPrefix/bin/$platformString/rg"
            '';
          };
        in
        # fallback to nixpkgs
        with pkgs-unstable.vscode-extensions;
        [
          alefragnani.bookmarks
          claude-code
          antyos.openscad
          bierner.markdown-mermaid
          bmalehorn.vscode-fish
          castwide.solargraph
          codezombiech.gitignore
          coolbear.systemd-unit-file
          dart-code.dart-code
          dart-code.flutter
          dbaeumer.vscode-eslint
          donjayamanne.githistory
          eamodio.gitlens
          editorconfig.editorconfig
          esbenp.prettier-vscode
          firefox-devtools.vscode-firefox-debug
          golang.go
          graphql.vscode-graphql
          graphql.vscode-graphql-syntax
          gruntfuggly.todo-tree
          hashicorp.terraform
          jebbs.plantuml
          jnoortheen.nix-ide
          llvm-vs-code-extensions.lldb-dap
          mads-hartmann.bash-ide-vscode
          mathiasfrohlich.kotlin
          mikestead.dotenv
          ms-azuretools.vscode-docker
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vscode-remote.remote-wsl
          ms-vscode.hexeditor
          ms-vscode.remote-explorer
          ms-vsliveshare.vsliveshare
          naumovs.color-highlight
          codex
          pkief.material-icon-theme
          pkief.material-product-icons
          shopify.ruby-lsp
          redhat.ansible
          redhat.java
          redhat.vscode-yaml
          rust-lang.rust-analyzer
          ryu1kn.partial-diff
          shopify.ruby-lsp
          # signageos.signageos-vscode-sops
          streetsidesoftware.code-spell-checker
          stylelint.vscode-stylelint
          tamasfe.even-better-toml
          tomoki1207.pdf
          visualstudioexptteam.intellicode-api-usage-examples
          visualstudioexptteam.vscodeintellicode
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
        ]
        ++ nix4vscodeExtensions;
    };
  };
}
