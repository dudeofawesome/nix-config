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
    modules = [
      pluginOverlay

      ./crater-lake

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.users.dudeofawesome = import ../../users/dudeofawesome;
        home-manager.extraSpecialArgs = {
          inherit dotfiles;
        };
      }
    ];
  };
}
