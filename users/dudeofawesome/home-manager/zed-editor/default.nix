{ lib, pkgs-unstable, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    # enableMcpIntegration = true;

    extensions = [
      "codex-acp"
      "dockerfile"
      "docker-compose"
      "bearded"
      "cspell"
      "d2"
      "env"
      "fish"
      "helm"
      "mermaid"
      "nix"
      "sql"
      "ssh-config"
    ];

    userKeymaps = lib.importJSON ./keybindings.json;
    userSettings = lib.importJSON ./zed-settings.json;
  };
}
