{ pkgs, ... }:
{
  programs.nh = {
    enable = true;
  };

  home.sessionVariables = {
    NH_SHOW_ACTIVATION_LOGS = "true";
  };
}
