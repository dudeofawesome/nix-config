{ lib
, inputs
, nixpkgs
, home-manager
, sops
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
          "dudeofawesome" = import ../../users/dudeofawesome { };
        };
      in
      [
        packageOverlays

        ./kings-canyon
        { _module.args.users = users; }

        sops.nixosModules.sops

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

  badlands-vm = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "dudeofawesome" = import ../../users/dudeofawesome { };
        };
      in
      [
        packageOverlays

        ./badlands-vm
        { _module.args.users = users; }

        sops.nixosModules.sops

        home-manager.nixosModules.home-manager
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

  monongahela = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules =
      let
        users = {
          "dudeofawesome" = import ../../users/dudeofawesome { };
        };
      in
      [
        packageOverlays

        ./monongahela
        { _module.args.users = users; }

        sops.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users = builtins.mapAttrs (key: val: val.settings) users;
            extraSpecialArgs = {
              inherit
                nix-vscode-extensions
                dudeofawesome_dotfiles
                ;
            };
          };
        }
      ];
  };
}
