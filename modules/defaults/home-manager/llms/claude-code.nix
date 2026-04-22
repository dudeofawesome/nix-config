{ lib, pkgs-unstable, ... }:
{
  programs.claude-code = {
    package = lib.mkDefault pkgs-unstable.claude-code;

    enableMcpIntegration = lib.mkDefault true;

    settings = {
      autoInstallIdeExtension = lib.mkDefault false;
    };
  };
}
