{ lib
, inputs
, nixpkgs
, home-manager
, nix-vscode-extensions
, dudeofawesome_dotfiles
, upaymeifixit_dotfiles
, packageOverlays
, darwin
, ...
}: {
  crater-lake = darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "dudeofawesome" = {
            settings = import ../../users/dudeofawesome;
            shell = nixpkgs.fish;
          };
        };
      in
      [
        packageOverlays

        ./crater-lake
        { _module.args.users = users; }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit
              nix-vscode-extensions
              dudeofawesome_dotfiles
              ;
          };
        }
      ];
  };

  badlands = darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "lorleans" = {
            settings = import ../../users/dudeofawesome;
            shell = nixpkgs.fish;
          };
        };
      in
      [
        packageOverlays

        ./badlands
        { _module.args.users = users; }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit
              nix-vscode-extensions
              dudeofawesome_dotfiles
              ;
          };
        }
      ];
  };

  joshs-paciolan-laptop = darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "joshuagibbs" = {
            settings = import ../../users/josh;
            shell = nixpkgs.fish;
          };
        };
      in
      [
        packageOverlays

        ./joshs-paciolan-laptop
        { _module.args.users = users; }

        home-manager.darwinModules.home-manager
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
