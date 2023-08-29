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
      bind
      curl
      dive
      eternal-terminal
      git
      htop
      jq
      ncdu
      nodePackages.prettier
      pciutils
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

      # Languages
      deno
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
