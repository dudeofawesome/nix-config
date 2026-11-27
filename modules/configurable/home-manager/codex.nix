{
  lib,
  config,
  pkgs,
  ...
}:
{
  programs.codex.mutableSettings = lib.mkDefault true;
  home.packages = lib.mkIf config.programs.codex.enable [ pkgs.codex-unlock ];
}
