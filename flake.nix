{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:dudeofawesome/dotfiles";
      flake = false;
    };

    vim-lumen = {
      url = "github:vimpostor/vim-lumen";
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
  };

  outputs =
    inputs@{ nixpkgs
    , nixpkgs-stable
    , home-manager
    , darwin
    , dotfiles
    , vim-lumen
    , fish-node-binpath
    , fish-node-version
    , fish-shell-integrations
    , fish-doa-tide-settings
    , ...
    }:
    let location = "$HOME/git/dudeofawesome/nix-config"; in
    {
      nixosConfigurations = (
        import ./hosts/nixos {
          inherit (nixpkgs) lib;
          inherit
            inputs
            nixpkgs
            nixpkgs-stable
            home-manager
            dotfiles
            vim-lumen
            fish-node-binpath
            fish-node-version
            fish-shell-integrations
            fish-doa-tide-settings
            location;
        }
      );

      darwinConfigurations = (
        import ./hosts/darwin {
          inherit (nixpkgs) lib;
          inherit
            inputs
            nixpkgs
            nixpkgs-stable
            home-manager
            dotfiles
            vim-lumen
            fish-node-binpath
            fish-node-version
            fish-shell-integrations
            fish-doa-tide-settings
            darwin;
        }
      );
    };
}
