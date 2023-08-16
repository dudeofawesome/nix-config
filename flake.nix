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
  };

  outputs = inputs@{ nixpkgs, nixpkgs-stable, home-manager, darwin, ... }:
    let location = "$HOME/git/dudeofawesome/nix-config"; in
    {
      nixosConfigurations = (
        import ./hosts/nixos {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable home-manager location;
        }
      );

      darwinConfigurations = (
        import ./hosts/darwin {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable home-manager darwin;
        }
      );
    };
}
