{ lib, pkgs-unstable, ... }:
{
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
