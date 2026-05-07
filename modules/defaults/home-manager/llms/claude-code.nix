{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  programs.claude-code = {
    package = lib.mkDefault pkgs-unstable.claude-code;

    enableMcpIntegration = lib.mkDefault true;

    settings = {
      autoInstallIdeExtension = lib.mkDefault false;
      statusLine = {
        command = lib.getExe pkgs.claude-pace;
        padding = 0;
        type = "command";
      };

      permissions = {
        allow = [
          "Bash(bash -n *)"
          "Bash(nix fmt *)"
          "Bash(nix build *)"
          "Bash(nix eval *)"
          "Bash(nix-prefetch-url *)"
        ];
      };
    };
  };
}
