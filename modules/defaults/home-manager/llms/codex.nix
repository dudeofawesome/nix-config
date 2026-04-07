{ pkgs-unstable, ... }:
{
  programs.codex = {
    package = pkgs-unstable.codex;

    enableMcpIntegration = true;

    settings = {
      notify = [
        "bash"
        "-lc"
        "afplay --volume 3 /System/Library/Sounds/Bottle.aiff"
      ];
    };
  };
}
