{ pkgs-unstable, ... }:
{
  programs.claude-code = {
    package = pkgs-unstable.claude-code;

    enableMcpIntegration = true;

    settings = {
      # permissions = { };
      autoInstallIdeExtension = false;
    };
  };
}
