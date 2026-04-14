{ lib, pkgs-unstable, ... }:
{
  programs.claude-code = {
    package = lib.mkDefault pkgs-unstable.claude-code;

    enableMcpIntegration = lib.mkDefault true;

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
  };
}
