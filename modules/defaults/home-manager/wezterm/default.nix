{ pkgs-stable, ... }:
{
  programs.wezterm = {
    enable = true;
    package = pkgs-stable.wezterm;
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
