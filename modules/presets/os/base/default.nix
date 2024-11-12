{ os, hostname, pkgs, lib, config, ... }:
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
      nil
      nix-du
      nix-tree
      # nixd
      nixpkgs-fmt
      nodePackages.prettier
      pciutils
      ripgrep
      tmux
      wget

      # Shells
      fish

      # Runtimes
      bun
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
