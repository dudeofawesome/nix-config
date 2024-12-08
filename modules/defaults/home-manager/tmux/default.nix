{
  lib,
  config,
  osConfig,
  ...
}:
{
  programs.tmux = {
    enable = true;

    clock24 = config.programs.doa-system-clock.show_24_hour;
    mouse = true;
    newSession = true;

    extraConfig = builtins.readFile ./tmux.conf;
  };
}
