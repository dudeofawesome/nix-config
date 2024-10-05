{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nur.url = "github:nix-community/NUR";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcasks = {
      url = "github:jacekszymanski/nixcasks";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
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

    fish-doa-tide-settings = {
      url = "github:dudeofawesome/fish-plugin-doa-tide-settings";
      flake = false;
    };

    fish-editor-updater = {
      url = "github:dudeofawesome/fish-plugin-editor-updater";
      flake = false;
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }:
    let
      location = "$HOME/git/dudeofawesome/nix-config";
      packageOverlays = ./overlays;
      usersModule = import ./users { inherit (nixpkgs) lib; };
    in
    {
      nixosConfigurations = (
        import ./hosts/nixos {
          inherit (nixpkgs) lib;
          inherit
            inputs
            usersModule
            packageOverlays
            location
            ;
        }
      );

      darwinConfigurations = (
        import ./hosts/darwin {
          inherit (nixpkgs) lib;
          inherit
            inputs
            usersModule
            packageOverlays
            ;
        }
      );
    };
}
