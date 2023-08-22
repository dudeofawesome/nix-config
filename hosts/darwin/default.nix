{ lib
, inputs
, nixpkgs
, home-manager
, dotfiles
, pluginOverlay
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
            shell = "fish";
          };
        };
      in
      [
        pluginOverlay

        ./crater-lake
        { _module.args.users = users; }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit dotfiles;
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
            shell = "fish";
          };
        };
      in
      [
        pluginOverlay

        ./badlands
        { _module.args.users = users; }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users = builtins.mapAttrs (key: val: val.settings) users;
          home-manager.extraSpecialArgs = {
            inherit dotfiles;
          };
        }
      ];
  };
}
