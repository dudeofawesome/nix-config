{ pkgs, ... }:
{
  # Temporary - this is broken for me, but I don't need to use it
  nix.linux-builder.enable = false;

  imports =
    [
    ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      arduino-cli
      ffmpeg
      gitlab-runner
      imagemagick
      k6
      lynx
      nmap

      # Languages
      go
      go-outline
      gopls
    ];
  };

  homebrew = {
    casks = [
      "battery"
      "zoom"
    ];
  };
}
