{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    # TODO: use `nixpkgs-YY.MM-darwin` for Darwin
    nixpkgs-linux-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    nix-std.url = "github:chessai/nix-std";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    home-manager = {
      url = "github:dudeofawesome/home-manager/fix/vscode-profile-dir-creation-25.05";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin-stable";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    dudeofawesome_dotfiles = {
      url = "github:dudeofawesome/dotfiles";
      flake = false;
    };

    upaymeifixit_dotfiles = {
      url = "github:upaymeifixit/dotfiles";
      flake = false;
    };

    vim-lumen = {
      url = "github:vimpostor/vim-lumen";
      flake = false;
    };

    fish-osx = {
      url = "github:oh-my-fish/plugin-osx";
      flake = false;
    };

    fish-node-binpath = {
      url = "github:dudeofawesome/plugin-node-binpath";
      flake = false;
    };

    fish-node-version = {
      url = "github:dudeofawesome/fish-plugin-node-version";
      flake = false;
    };

    fish-shell-integrations = {
      url = "github:dudeofawesome/fish-plugin-shell-integrations";
      flake = false;
    };

    fish-editor-updater = {
      url = "github:dudeofawesome/fish-plugin-editor-updater";
      flake = false;
    };

    fish-nvm = {
      url = "github:jorgebucaran/nvm.fish";
      flake = false;
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ nixpkgs-linux-stable, nixpkgs-unstable, ... }:
    let
      lib = nixpkgs-linux-stable.lib;
      params = {
        inherit
          inputs
          lib
          ;
        location = "$HOME/git/dudeofawesome/nix-config";
        usersModule = import ./users { inherit lib; };
        packageOverlays = ./overlays;
      };

      forAllSystems =
        function:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          function (
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      nixosConfigurations = import ./hosts/nixos params;
      darwinConfigurations = import ./hosts/darwin params;

      # run `nix fmt` to format all files
      formatter = forAllSystems (nixpkgs: nixpkgs.nixfmt-rfc-style);
    };
}
