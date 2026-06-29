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
          nix4vscodeExtensions = pkgs-unstable.nix4vscode.forVscode [
            "beardedbear.beardedtheme"
            "blueglassblock.better-json5"
            "bpruitt-goddard.mermaid-markdown-syntax-highlighting"
            "drknoxy.eslint-disable-snippets"
            "eeyore.yapf"
            "effectful-tech.effect-vscode"
            "fabiospampinato.vscode-diff"
            "flesler.url-encode"
            "github.vscode-github-actions"
            "github.vscode-pull-request-github"
            "inferrinizzard.prettier-sql-vscode"
            "mermaidchart.vscode-mermaid-chart"
            "mrmlnc.vscode-scss"
            "ms-kubernetes-tools.vscode-kubernetes-tools"
            "mxsdev.typescript-explorer"
            "oven.bun-vscode"
            "seeker-dk.node-modules-viewer"
            "semanticdiff.semanticdiff"
            "terrastruct.d2"
            "tomoyukim.vscode-mermaid-editor"
            "tyriar.lorem-ipsum"
            "ultram4rine.vscode-choosealicense"
            "vitest.explorer"
            "vstirbu.vscode-mermaid-preview"
            "yutengjing.open-in-external-app"
          ];
        in
        # fallback to nixpkgs
        with pkgs-unstable.vscode-extensions;
        [
          alefragnani.bookmarks
          bierner.markdown-mermaid
          bmalehorn.vscode-fish
          codezombiech.gitignore
          dbaeumer.vscode-eslint
          donjayamanne.githistory
          eamodio.gitlens
          editorconfig.editorconfig
          esbenp.prettier-vscode
          golang.go
          gruntfuggly.todo-tree
          jebbs.plantuml
          jnoortheen.nix-ide
          mads-hartmann.bash-ide-vscode
          mikestead.dotenv
          ms-azuretools.vscode-docker
          ms-python.python
          ms-python.vscode-pylance
          ms-toolsai.jupyter
          ms-vscode.hexeditor
          naumovs.color-highlight
          redhat.vscode-yaml
          ryu1kn.partial-diff
          streetsidesoftware.code-spell-checker
          stylelint.vscode-stylelint
          tamasfe.even-better-toml
          tomoki1207.pdf
          visualstudioexptteam.intellicode-api-usage-examples
          visualstudioexptteam.vscodeintellicode
          wmaurer.change-case
          yoavbls.pretty-ts-errors
          yzhang.markdown-all-in-one
        ]
        ++ nix4vscodeExtensions;
    };
  };
}
