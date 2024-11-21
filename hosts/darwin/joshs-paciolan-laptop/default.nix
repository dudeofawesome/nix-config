{ pkgs, ... }: {
  imports = [
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
