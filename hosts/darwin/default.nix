{ lib, inputs, nixpkgs, home-manager, darwin, ... }: {
  crater-lake = darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      ./crater-lake

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.dudeofawesome = import ../../users/dudeofawesome;
      }
    ];
  };
}
