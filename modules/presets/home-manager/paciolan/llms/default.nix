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
          prefixed = prefix: map (tool: "${prefix}${tool}");
        in
        {
          allow = lib.flatten [
            (prefixed "mcp__claude_ai_Atlassian__" [
              "atlassianUserInfo"
              "fetch"
              "getAccessibleAtlassianResources"
              "getConfluenceCommentChildren"
              "getConfluencePage"
              "getConfluencePageDescendants"
              "getConfluencePageFooterComments"
              "getConfluencePageInlineComments"
              "getConfluenceSpaces"
              "getIssueLinkTypes"
              "getJiraIssue"
              "getJiraIssueRemoteIssueLinks"
              "getJiraIssueTypeMetaWithFields"
              "getJiraProjectIssueTypesMetadata"
              "getPagesInConfluenceSpace"
              "getTransitionsForJiraIssue"
              "getVisibleJiraProjects"
              "lookupJiraAccountId"
              "search"
              "searchConfluenceUsingCql"
              "searchJiraIssuesUsingJql"
            ])

            (prefixed "mcp__claude_ai_Slack__" [
              "slack_read_canvas"
              "slack_read_channel"
              "slack_read_thread"
              "slack_read_user_profile"
              "slack_search_channels"
              "slack_search_public"
              "slack_search_public_and_private"
              "slack_search_users"
            ])

            (prefixed "mcp__${hm-plugin-name}_gitlab__" [
              "download_attachment"
              "download_job_artifacts"
              "download_release_asset"
              "get_branch_diffs"
              "get_commit"
              "get_commit_diff"
              "get_deployment"
              "get_draft_note"
              "get_environment"
              "get_file_contents"
              "get_job_artifact_file"
              "get_label"
              "get_merge_request"
              "get_merge_request_approval_state"
              "get_merge_request_conflicts"
              "get_merge_request_diffs"
              "get_merge_request_file_diff"
              "get_merge_request_note"
              "get_merge_request_notes"
              "get_merge_request_version"
              "get_namespace"
              "get_pipeline"
              "get_pipeline_job"
              "get_pipeline_job_output"
              "get_project"
              "get_project_events"
              "get_release"
              "get_repository_tree"
              "get_users"
              "list_commits"
              "list_deployments"
              "list_draft_notes"
              "list_environments"
              "list_events"
              "list_group_iterations"
              "list_group_projects"
              "list_job_artifacts"
              "list_labels"
              "list_merge_request_changed_files"
              "list_merge_request_diffs"
              "list_merge_request_versions"
              "list_merge_requests"
              "list_namespaces"
              "list_pipeline_jobs"
              "list_pipeline_trigger_jobs"
              "list_pipelines"
              "list_project_members"
              "list_projects"
              "list_releases"
              "search_code"
              "search_group_code"
              "search_project_code"
              "search_repositories"
              "verify_namespace"
            ])

            "mcp__${hm-plugin-name}_aws__aws___suggest_aws_commands"

            (prefixed "mcp__${hm-plugin-name}_kubernetes__" [
              "configuration_contexts_list"
              "configuration_view"
              "events_list"
              "namespaces_list"
              "nodes_log"
              "nodes_stats_summary"
              "nodes_top"
              "pods_get"
              "pods_list"
              "pods_list_in_namespace"
              "pods_log"
              "pods_top"
              "resources_get"
              "resources_list"
            ])
          ];
        };

      autoInstallIdeExtension = lib.mkDefault false;
    };

    skills = {
      commit-and-mr = ./skills/commit-and-mr;
      create-jira-item = ./skills/create-jira-item;
      full-feature-workflow = ./skills/full-feature-workflow;
      notify-blame = ./skills/notify-blame;
      person-to-user-map = ./skills/person-to-user-map;
      write-claude-tooling = ./skills/write-claude-tooling;
    };
  };

  home.file = {
    "git/paciolan/AGENTS.md".source = ./memories/git-paciolan.md;
    "git/paciolan/CLAUDE.md".text = "@AGENTS.md";
  };
}
