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
    specialArgs = {
      inherit inputs;
      hostname = "kings-canyon";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "server";
    };
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
          home-manager = import ../../modules/host-home-manager.nix {
            inputs = inputs;
            users = users;

            nix-vscode-extensions = nix-vscode-extensions;
            dudeofawesome_dotfiles = dudeofawesome_dotfiles;
            upaymeifixit_dotfiles = upaymeifixit_dotfiles;
          };
        }
      ];
  };

  badlands-vm = lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs;
      hostname = "badlands-vm";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "local-vm";
    };
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
          home-manager = import ../../modules/host-home-manager.nix {
            inputs = inputs;
            users = users;

            nix-vscode-extensions = nix-vscode-extensions;
            dudeofawesome_dotfiles = dudeofawesome_dotfiles;
            upaymeifixit_dotfiles = upaymeifixit_dotfiles;
          };
        }
      ];
  };

  monongahela = lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      hostname = "monongahela";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "scratch";
    };
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
          home-manager = import ../../modules/host-home-manager.nix {
            inputs = inputs;
            users = users;

            nix-vscode-extensions = nix-vscode-extensions;
            dudeofawesome_dotfiles = dudeofawesome_dotfiles;
            upaymeifixit_dotfiles = upaymeifixit_dotfiles;
          };
        }
      ];
  };
}
