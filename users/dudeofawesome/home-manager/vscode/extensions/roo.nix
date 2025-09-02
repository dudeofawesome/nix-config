{ ... }:
{
  programs.vscode = {
    extensionSettings = {
      "rooveterinaryinc.roo-cline" = {
        mcpServers = {
          context7 = {
            command = "npx";
            args = [
              "-y"
              "@upstash/context7-mcp@latest"
            ];
            env = {
              "DEFAULT_MINIMUM_TOKENS" = "";
            };
            alwaysAllow = [
              "resolve-library-id"
              "get-library-docs"
            ];
          };
          sequentialthinking = {
            command = "npx";
            args = [
              "-y"
              "@modelcontextprotocol/server-sequential-thinking@latest"
            ];
          };
          "effect-docs" = {
            command = "npx";
            args = [
              "-y"
              "effect-mcp@latest"
            ];
            alwaysAllow = [
              "effect_doc_search"
              "get_effect_doc"
            ];
          };
        };
      };
    };
  };
}
