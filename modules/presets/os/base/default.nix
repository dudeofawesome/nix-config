{
  pkgs,
  pkgs-unstable,
  os,
  hostname,
  ...
}:
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
      pkgs-unstable.nixfmt-rfc-style
      pkgs-unstable.nodePackages.prettier
      pciutils
      pstree
      ripgrep
      rsync
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
    nerd-fonts.fira-code
  ];
}
