{ lib
, inputs
, nixpkgs
, home-manager
, dotfiles
, pluginOverlay
, ...
}: {
  kings-canyon = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      pluginOverlay

      ./kings-canyon

      home-manager.nixosModules.home-manager
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

  crater-lake-vm = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      pluginOverlay

      ./crater-lake-vm

      home-manager.nixosModules.home-manager
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
