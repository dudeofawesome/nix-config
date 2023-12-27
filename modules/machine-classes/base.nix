{ pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  imports = [
    ../sops.nix
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

  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';

    settings = {
      trusted-users =
        if (isLinux) then [ "root" "@wheel" ]
        else if (isDarwin) then [ "admin" ]
        else [ ];
    };
  };
  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}
