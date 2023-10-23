{ lib
, inputs
, nixpkgs
, home-manager
, nix-vscode-extensions
, dudeofawesome_dotfiles
, upaymeifixit_dotfiles
, packageOverlays
, ...
}: {
  kings-canyon = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "lorleans" = {
            settings = import ../../users/dudeofawesome/settings;
            shell = nixpkgs.fish;
          };
        };
      in
      [
        packageOverlays

        ./kings-canyon
        { _module.args.users = users; }

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit
              nix-vscode-extensions
              dudeofawesome_dotfiles
              upaymeifixit_dotfiles
              ;
          };
        }
      ];
  };

  crater-lake-vm = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "lorleans" = {
            settings = import ../../users/dudeofawesome/settings;
            shell = nixpkgs.fish;
          };
        };
      in
      [
        packageOverlays

        ./crater-lake-vm
        { _module.args.users = users; }

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit
              nix-vscode-extensions
              dudeofawesome_dotfiles
              upaymeifixit_dotfiles
              ;
          };
        }
      ];
  };
}
