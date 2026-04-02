{ pkgs-unstable, ... }:
{
  programs = {
    mcp = {
      enable = true;
      servers = {
        atlassian = {
          type = "http";
          url = "https://mcp.atlassian.com/v1/mcp";
        };
        # gitlab = { # not yet supported by pac's gitlab deployment
        #   type = "http";
        #   url = "https://gitlabdev.paciolan.info/api/v4/mcp";
        # };
        # aws
        # k8s
        # slack
      };
    };

    claude-code = {
      enable = true;
      package = pkgs-unstable.claude-code;
      enableMcpIntegration = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.agents
      # agents = { };
      # commands = { };
      # hooks = { };
      # memory = { };
      # rules = { };
      # settings = {
      #   permissions = { };
      # };
      skills = {
        jira = ./skills/jira-defaults.md;
      };
    };

    codex = {
      enable = true;
      package = pkgs-unstable.codex;
      # enableMcpIntegration = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.codex.custom-instructions
    };
  };
}
