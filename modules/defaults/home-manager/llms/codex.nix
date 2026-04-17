{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  home.packages = lib.flatten [
    (lib.optional (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.codex-desktop) pkgs.codex-desktop)
  ];

  programs.codex = {
    package = lib.mkDefault pkgs-unstable.codex;

    enableMcpIntegration = lib.mkDefault true;

    settings = {
      # TODO: make this also flash the screen if muted
      # TODO: make this alert only when codex is done with a turn or asking for permission
      notify = [
        "bash"
        "-lc"
        "afplay --volume 3 /System/Library/Sounds/Bottle.aiff"
      ];
    };
  };
}
