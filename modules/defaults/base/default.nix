{ os, pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  imports = [
    ./${os}.nix
    ../../defaults/sops.nix
    ../../defaults/nix.nix
  ];

  fonts = {
    fontDir.enable = true;
  };

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
      gnumake
      htop
      jq
      most
      nixd
      nixpkgs-fmt
      nodePackages.prettier
      pciutils
      ripgrep
      rnix-lsp
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
      nodejs
      python3
    ];
  };

  programs.fish.enable = true;
}
