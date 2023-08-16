{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      })
    ];
  };

  environment = {
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      # Utilities
      act
      ansible
      awscli2
      bat
      bind
      bottom
      curl
      dive
      eternal-terminal
      git
      htop
      jq
      most
      ncdu
      nodePackages.prettier
      pciutils
      ripgrep
      rnix-lsp
      tmux
      wget

      # Shells
      fish
      fishPlugins.tide
      fishPlugins.autopair

      # Languages
      deno
      ruby
      nodejs-18_x
    ];
  };

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  services = {
    nix-daemon.enable = true; # Auto upgrade daemon
  };

  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };
  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}
