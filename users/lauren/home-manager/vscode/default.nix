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
          nix4vscode = (import ../../../dudeofawesome/home-manager/vscode/extensions.nix) {
            inherit pkgs lib;
          };
        in
        # fallback to nixpkgs
        with pkgs-unstable.vscode-extensions;
        [
          alefragnani.bookmarks
          nix4vscode.beardedbear.beardedtheme
          bierner.markdown-mermaid
          nix4vscode.blueglassblock.better-json5
          bmalehorn.vscode-fish
          nix4vscode.bpruitt-goddard.mermaid-markdown-syntax-highlighting
          codezombiech.gitignore
          dbaeumer.vscode-eslint
          donjayamanne.githistory
          nix4vscode.drknoxy.eslint-disable-snippets
          eamodio.gitlens
          editorconfig.editorconfig
          nix4vscode.eeyore.yapf
          nix4vscode.effectful-tech.effect-vscode
          esbenp.prettier-vscode
          nix4vscode.fabiospampinato.vscode-diff
          nix4vscode.flesler.url-encode
          nix4vscode.github.vscode-github-actions
          nix4vscode.github.vscode-pull-request-github
          golang.go
          gruntfuggly.todo-tree
          nix4vscode.inferrinizzard.prettier-sql-vscode
          jebbs.plantuml
          jnoortheen.nix-ide
          mads-hartmann.bash-ide-vscode
          nix4vscode.mermaidchart.vscode-mermaid-chart
          mikestead.dotenv
          nix4vscode.mrmlnc.vscode-scss
          ms-azuretools.vscode-docker
          nix4vscode.ms-kubernetes-tools.vscode-kubernetes-tools
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-vscode.hexeditor
          nix4vscode.mxsdev.typescript-explorer
          naumovs.color-highlight
          nix4vscode.oven.bun-vscode
          redhat.vscode-yaml
          ryu1kn.partial-diff
          nix4vscode.seeker-dk.node-modules-viewer
          nix4vscode.semanticdiff.semanticdiff
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
          wmaurer.change-case
          yoavbls.pretty-ts-errors
          nix4vscode.yutengjing.open-in-external-app
          yzhang.markdown-all-in-one
        ];
    };
  };
}
