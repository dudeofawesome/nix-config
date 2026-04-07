{
  pkgs,
  lib,
  config,
  ...
}:
{
  programs.claude-code = {
    enable = true;

    mcpServers = {
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

              exec ${lib.getExe pkgs.mcp-gitlab}
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
      # slack
    };
    settings = {
      permissions = {
        # allow = [];
        # deny = [];
      };
    };

    skills = {
      commit-and-mr = ./skills/commit-and-mr.md;
      create-jira-item = ./skills/create-jira-item.md;
      notify-blame = ./skills/notify-blame.md;
      person-to-user-map = ./skills/person-to-user-map.md;
      strict-lint = ./skills/strict-lint.md;
    };
  };

  home.file = {
    # "git/paciolan/AGENTS.md".source = ./memories/git-paciolan.md;
    # "git/paciolan/CLAUDE.md".content = "@AGENTS.md";
  };
}
