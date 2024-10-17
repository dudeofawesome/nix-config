{ os, hostname, pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  imports = [
    ./${os}.nix
    ../../defaults/sops.nix
    ../../defaults/nix.nix
  ];

  environment = {
    shells = with pkgs; [ fish ];
    systemPackages = with pkgs; [
      # Utilities
      _1password
      act
      ansible
      awscli2
      bat
      bind
      bottom
      curl
      dive
      dua
      eternal-terminal
      fd
      git
      htop
      jq
      moar
      most
      nil
      nix-tree
      # nixd
      nixpkgs-fmt
      nodePackages.prettier
      pciutils
      ripgrep
      rubyPackages.prettier_print
      rubyPackages.syntax_tree
      rubyPackages.syntax_tree-haml
      rubyPackages.syntax_tree-rbs
      tmux
      vim-full
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

  networking = {
    hostName = hostname;
  };

  programs.fish.enable = true;
}
