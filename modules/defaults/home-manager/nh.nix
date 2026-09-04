{ config, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "${config.home.homeDirectory}/git/dudeofawesome/nix-config/";
  };

  launchd.agents.nh-clean.config.EnvironmentVariables.PATH =
    "/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";

  home.sessionVariables = {
    NH_SHOW_ACTIVATION_LOGS = "true";
  };
}
