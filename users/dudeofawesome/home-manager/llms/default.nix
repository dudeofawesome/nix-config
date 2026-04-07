{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
{
  programs = {
    mcp = {
      enable = true;
      servers = {
        kubernetes.command = lib.getExe pkgs.kubernetes-mcp-server;
      };
    };

    claude-code = {
      skills = {
        jira-defaults = ./skills/jira-defaults.md;
      };
    };

    codex = {
      enable = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.codex.custom-instructions
    };
  };
}
