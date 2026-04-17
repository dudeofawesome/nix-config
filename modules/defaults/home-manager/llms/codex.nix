{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  home.packages = with pkgs; [
    codex-desktop
  ];

  programs.codex = {
    package = lib.mkDefault pkgs-unstable.codex;

    enableMcpIntegration = lib.mkDefault true;

    settings = {
      # TODO: make this also flash the screen if muted
      notify = [
        "bash"
        "-lc"
        "afplay --volume 3 /System/Library/Sounds/Bottle.aiff"
      ];
    };
  };
}
