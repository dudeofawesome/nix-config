{ pkgs, pkgs-unstable, lib, machine-class, ... }:
{
  # Temporary - this is broken for me, but I don't need to use it
  nix.linux-builder.enable = false;

  imports = lib.flatten [
    (lib.optional (machine-class == "pc") ../../../modules/presets/os/paciolan.nix)
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
