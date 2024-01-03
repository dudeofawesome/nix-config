{ hostname, pkgs, ... }:
{
  imports = [
    ../configuration.nix
    ../../../modules/machine-classes/pc.nix
    ../../../users/josh/os/darwin.nix
  ];

  networking = {
    hostName = hostname;
  };

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
    ];
  };
}
