{ pkgs, pkgs-unstable, os, hostname, ... }:
with pkgs.stdenv.targetPlatform;
{
  imports = [
    ./default.${os}.nix
    ../../../configurable/os
    ../../../defaults
  ];

  environment = {
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      # Utilities
      bat
      bind
      bottom
      curl
      dua
      eternal-terminal
      fd
      git
      htop
      jq
      moar
      most
      pkgs-unstable.nil
      nix-du
      nix-tree
      # nixd
      nixfmt-rfc-style
      nodePackages.prettier
      pciutils
      ripgrep
      rsync
      tmux
      wget

      # Shells
      fish

      # Runtimes
      pkgs-unstable.bun
      ruby
      nodejs_20 # this should always use the latest LTS
      python3

      # Libraries
      gcc
      gnumake
      libllvm
    ];
  };

  networking.hostName = hostname;

  programs.fish.enable = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
  ];
}
