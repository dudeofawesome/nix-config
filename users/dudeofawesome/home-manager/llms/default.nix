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
        atlassian.url = "https://mcp.atlassian.com/v1/mcp";
        # gitlab = { # not yet supported by pac's gitlab deployment
        #   type = "http";
        #   url = "https://gitlabdev.paciolan.info/api/v4/mcp";
        # };
        gitlab =
          let
            command = lib.getExe (
              pkgs.writeShellScriptBin "gitlab-mcp" ''
                export GITLAB_PERSONAL_ACCESS_TOKEN="$(${
                  let
                    op = config.programs._1password-cli;
                  in
                  if (config.sops.secrets ? "users/dudeofawesome/gitlabdev.paciolan.info/token") then
                    "cat ${config.sops.secrets."users/dudeofawesome/gitlabdev.paciolan.info/token".path}"
                  else if (op.enable) then
                    "${lib.getExe op.package} item get 'GitLab Personal Access Token' --vault Paciolan --fields label='token' --reveal"
                  else
                    throw "No gitlab PAT source configured."
                })"

                exec ${lib.getExe' pkgs.bun "bunx"} -y @zereight/mcp-gitlab@2.0.35
              ''
            );
          in
          {
            inherit command;
            env = {
              GITLAB_API_URL = "https://gitlabdev.paciolan.info/api/v4";
              GITLAB_TOOLSETS = builtins.concatStringsSep "," [
                "merge_requests"
                # "issues"
                "repositories"
                "branches"
                "projects"
                "labels"
                "pipelines"
                # "milestones"
                # "wiki"
                "releases"
                "users"
                "search"
              ];
            };
          };
        aws =
          let
            op = lib.getExe config.programs._1password-cli.package;
            jq = "${lib.getExe pkgs.jq} --raw-output";
            command = lib.getExe (
              pkgs.writeShellScriptBin "aws-mcp" ''
                op_data="$(
                  ${op} item get 'AWS Access Key' \
                    --vault Paciolan \
                    --fields label='access key id',label='secret access key',label='default region' \
                    --reveal --format json \
                  | ${jq} 'map({key: .label, value}) | from_entries'
                )"

                export AWS_ACCESS_KEY_ID="$(echo "$op_data" | ${jq} '."access key id"')"
                export AWS_SECRET_ACCESS_KEY="$(echo "$op_data" | ${jq} '."secret access key"')"
                export AWS_DEFAULT_REGION="$(echo "$op_data" | ${jq} '."default region"')"

                exec ${lib.getExe' pkgs.uv "uvx"} mcp-proxy-for-aws@latest \
                  "https://aws-mcp.us-east-1.api.aws/mcp" \
                  --metadata "AWS_REGION=$AWS_DEFAULT_REGION" \
                  --read-only
              ''
            );
          in
          {
            inherit command;
          };
        # k8s
        # slack
      };
    };

    claude-code = {
      enable = true;
      enableMcpIntegration = true;
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.agents
      # agents = { };
      # commands = { };
      # hooks = { };
      # memory = { };
      # rules = { };
      settings = {
        permissions = {
          # allow = [];
          # deny = [];
        };
      };
      skills = {
        jira-defaults = ./skills/jira-defaults.md;
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
