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

    codex =
      let
        codexOnePasswordEnv = {
          # Match each environment variable to a 1Password secret reference.
          GITHUB_PAT = "op://Private/Github PAT - dudeofawesome/token";
        };

        codexPackage =
          let
            op = lib.getExe config.programs._1password-cli.package;
            wrappedCodex = pkgs.writeShellScript "codex" ''
              set -euo pipefail

              ${lib.concatLines (
                lib.mapAttrsToList (
                  name: reference: ''export ${name}="$(${op} read ${lib.escapeShellArg reference})"''
                ) codexOnePasswordEnv
              )}

              exec ${lib.getExe pkgs-unstable.codex} "$@"
            '';
          in
          pkgs.symlinkJoin {
            name = "codex-with-1password-env";
            paths = [ pkgs-unstable.codex ];
            postBuild = ''
              rm "$out/bin/codex"
              ln -s ${wrappedCodex} "$out/bin/codex"
            '';
          };
      in
      {
        enable = true;
        package = codexPackage;

        # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.codex.custom-instructions
        settings.mcp_servers = {
          github = {
            url = "https://api.githubcopilot.com/mcp/";
            bearer_token_env_var = "GITHUB_PAT";
          };
        };
      };
  };
}
