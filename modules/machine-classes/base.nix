{ pkgs, lib, ... }:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
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

  programs.fish.enable = true;

  console = {
    # TODO: set custom console font
    #   https://github.com/Anomalocaridid/dotfiles/blob/fcd37335d9799a9efd5e0c9aacdd12ab6283a259/modules/theming.nix#L4
    # enable setting TTY keybaord layout
    useXkbConfig = true;
  };

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
  };
  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}
