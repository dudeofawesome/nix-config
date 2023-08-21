{ lib
, inputs
, nixpkgs
, home-manager
, dotfiles
, vim-lumen
, fish-node-binpath
, fish-node-version
, fish-shell-integrations
, fish-doa-tide-settings
, ...
}: {
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
        home-manager.extraSpecialArgs = {
          inherit
            dotfiles
            vim-lumen
            fish-node-binpath
            fish-node-version
            fish-shell-integrations
            fish-doa-tide-settings
            ;
        };
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
        home-manager.extraSpecialArgs = {
          inherit
            dotfiles
            vim-lumen
            fish-node-binpath
            fish-node-version
            fish-shell-integrations
            fish-doa-tide-settings
            ;
        };
      }
    ];
  };
}
