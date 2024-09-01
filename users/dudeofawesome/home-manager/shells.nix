{ pkgs, lib, osConfig, ... }: {
  programs = {
    atuin = {
      enable = true;
      settings.sync_address = "https://atuin.orleans.io";
    };

    process-compose = {
      enable = true;

      settings = {
        theme = "Default";
        sort = {
          by = "NAME";
          isReversed = false;
        };
      };

      shortcuts = {
        help.shortcut = "?";
        full_screen.shortcut = "F1";
        log_screen.shortcut = "F2";
        process_screen.shortcut = "F3";
        process_scale.shortcut = "F20";
        process_info.shortcut = "F7";
      };
    };
  };
}
