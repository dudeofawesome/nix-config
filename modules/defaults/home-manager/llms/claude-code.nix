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
        allow = lib.flatten [
          "WebFetch"
          "WebSearch"

          "Bash(bash -n *)"

          (map (cmd: "Bash(${cmd})") [
            "nix fmt *"
            "nix build *"
            "nix eval *"
            "nix-prefetch-url *"
          ])
        ];
      };
    };
  };
}
