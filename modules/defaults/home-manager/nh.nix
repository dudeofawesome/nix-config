{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "~/git/dudeofawesome/nix-config/";
  };

  home.sessionVariables = {
    NH_SHOW_ACTIVATION_LOGS = "true";
  };
}
