{ pkgs, lib, machine-class, config, ... }:
with lib;
let
  userDir =
    if pkgs.stdenv.targetPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else if pkgs.stdenv.targetPlatform.isLinux then
      ".config/Code/User"
    else
      abort;
  vscodeConfigFilePath = "${userDir}/settings.json";
in
{
  home.packages = with pkgs; [
    rubyPackages.solargraph
  ];

  # home.file.vscode_settings = {
  #   target = vscodeConfigFilePath;
  #   source = config.lib.file.mkOutOfStoreSymlink ./vscode-settings.json;
  # };
  home.activation.createMutableVSCodeSettings = mkIf config.programs.vscode.enable (
    hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$(dirname ~/"${vscodeConfigFilePath}")"

      # Detect OS theme setting
      os_theme="$(/usr/bin/defaults read -g AppleInterfaceStyle 2> /dev/null || echo "Light")"
      # Read preferred color theme
      theme="$(grep -Po '(?<="workbench.preferred'"$os_theme"'ColorTheme": ").+(?=")' "${./vscode-settings.json}")"
      $DRY_RUN_CMD cat "${./vscode-settings.json}" \
        `# Modify the selected theme to prevent jerk` \
        | sed -Ee 's/("workbench.colorTheme"): "(.+)"/\1: "'"$theme"'"/i' \
        `# Overwrite VS Code settings` \
        | $DRY_RUN_CMD tee ~/"${vscodeConfigFilePath}" > /dev/null
    ''
  );

  programs = {
    vscode = {
      enable = machine-class == "pc";

      extensions =
        with pkgs.vscodeExtensions.extensions.${pkgs.system}.vscode-marketplace;
        [
          pkgs.vscodeExtensions.extensions.${pkgs.system}.vscode-marketplace."1password".op-vscode
          alefragnani.bookmarks
          antyos.openscad
          ashrafhadden.dracula-dot-min
          beardedbear.beardedtheme
          bierner.markdown-mermaid
          bmalehorn.vscode-fish
          bpruitt-goddard.mermaid-markdown-syntax-highlighting
          bradlc.vscode-tailwindcss
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
          effectful-tech.effect-vscode
          equinusocio.vsc-material-theme
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
          mrmlnc.vscode-json5
          mrmlnc.vscode-scss
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-python.black-formatter
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
          semanticdiff.semanticdiff
          shd101wyy.markdown-preview-enhanced
          shopify.ruby-lsp
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

      # See `home.activation.createMutableVSCodeSettings` for my workaround to
      #   have mutable settings.
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
