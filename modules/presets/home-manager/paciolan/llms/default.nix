{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ../../../../defaults/home-manager/llms/claude-code.nix
  ];

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
      permissions =
        let
          hm-plugin-name = "plugin_claude-code-home-manager";
        in
        {
          allow = [
            # TODO: it looks like wildcards maybe don't work in the middle?
            "mcp__claude_ai_Atlassian__get*"
            "mcp__claude_ai_Atlassian__search*"
            "mcp__claude_ai_Atlassian__lookup*"
            "mcp__claude_ai_Atlassian__atlassianUserInfo"
            "mcp__claude_ai_Atlassian__fetchAtlassian"
            "mcp__${hm-plugin-name}_atlassian__get*"
            "mcp__${hm-plugin-name}_atlassian__search*"
            "mcp__${hm-plugin-name}_atlassian__lookup*"
            "mcp__${hm-plugin-name}_atlassian__atlassianUserInfo"
            "mcp__${hm-plugin-name}_atlassian__fetchAtlassian"

            "mcp__claude_ai_Slack__slack_read_*"
            "mcp__claude_ai_Slack__slack_search*"

            # mcp__plugin_claude-code-home-manager_gitlab__list_merge_requests
            "mcp__${hm-plugin-name}_gitlab__download_*"
            "mcp__${hm-plugin-name}_gitlab__get_*"
            "mcp__${hm-plugin-name}_gitlab__list_*"
            "mcp__${hm-plugin-name}_gitlab__search_*"
            "mcp__${hm-plugin-name}_gitlab__verify_*"

            "mcp__${hm-plugin-name}_aws__aws___suggest_aws_commands"

            "mcp__${hm-plugin-name}_kubernetes__configuration_contexts_list"
            "mcp__${hm-plugin-name}_kubernetes__configuration_view"
            "mcp__${hm-plugin-name}_kubernetes__events_list"
            "mcp__${hm-plugin-name}_kubernetes__namespaces_list"
            "mcp__${hm-plugin-name}_kubernetes__nodes_log"
            "mcp__${hm-plugin-name}_kubernetes__nodes_stats_summary"
            "mcp__${hm-plugin-name}_kubernetes__nodes_top"
            "mcp__${hm-plugin-name}_kubernetes__pods_get"
            "mcp__${hm-plugin-name}_kubernetes__pods_list"
            "mcp__${hm-plugin-name}_kubernetes__pods_list_in_namespace"
            "mcp__${hm-plugin-name}_kubernetes__pods_log"
            "mcp__${hm-plugin-name}_kubernetes__pods_top"
            "mcp__${hm-plugin-name}_kubernetes__resources_get"
            "mcp__${hm-plugin-name}_kubernetes__resources_list"
          ];
        };

      autoInstallIdeExtension = lib.mkDefault false;
    };

    skills = {
      commit-and-mr = ./skills/commit-and-mr;
      create-jira-item = ./skills/create-jira-item.md;
      notify-blame = ./skills/notify-blame;
      person-to-user-map = ./skills/person-to-user-map.md;
      write-claude-tooling = ./skills/write-claude-tooling.md;
    };
  };

  home.file = {
    # "git/paciolan/AGENTS.md".source = ./memories/git-paciolan.md;
    # "git/paciolan/CLAUDE.md".content = "@AGENTS.md";
  };
}
