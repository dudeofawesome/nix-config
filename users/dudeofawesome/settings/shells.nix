{ pkgs, lib, osConfig, ... }: {
  programs = {
    atuin = {
      enable = true;
      settings.sync_address = "https://atuin.orleans.io";
    };
  };
}
