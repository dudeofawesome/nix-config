{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    # TODO: use `nixpkgs-YY.MM-darwin` for Darwin
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nix-std.url = "github:chessai/nix-std";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
    inputs@{ nixpkgs-stable, nixpkgs-unstable, ... }:
    let
      lib = nixpkgs-stable.lib;
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
