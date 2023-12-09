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
      most
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
    ];
  };

  services = {
    nix-daemon.enable = true; # Auto upgrade daemon
  };

  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      # TODO: how do we specify GC interval for nixos?
      interval.Day = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin 7;
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
