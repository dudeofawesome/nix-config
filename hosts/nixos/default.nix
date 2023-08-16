{ lib, inputs, nixpkgs, home-manager, ... }: {
  kings-canyon = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./kings-canyon

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.dudeofawesome = import ../../users/dudeofawesome;
      }
    ];
  };

  crater-lake-vm = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./crater-lake-vm

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.dudeofawesome = import ../../users/dudeofawesome;
      }
    ];
  };
}
