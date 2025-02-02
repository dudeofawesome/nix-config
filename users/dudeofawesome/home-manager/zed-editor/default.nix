{ lib, pkgs-unstable, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;

    extensions = [
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

    userSettings = lib.importJSON ./zed-settings.json;
  };
}
