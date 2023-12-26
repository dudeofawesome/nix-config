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
  kings-canyon =
    let
      hostname = "kings-canyon";
      arch = "x86_64";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "server";
      users = {
        "dudeofawesome" = import ../../users/dudeofawesome { };
      };
    in
    lib.nixosSystem {
      system = "${arch}-${os}";
      specialArgs = {
        inherit
          inputs
          hostname
          arch
          os
          owner
          machine-class
          ;
      };
      modules = [
        packageOverlays

        ./${hostname}
        { _module.args.users = users; }

        sops.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager = import ../../modules/host-home-manager.nix {
            inherit
              inputs

              users
              hostname
              os
              owner
              machine-class

              nix-vscode-extensions
              dudeofawesome_dotfiles
              upaymeifixit_dotfiles
              ;
          };
        }
      ];
    };

  badlands-vm =
    let
      hostname = "badlands-vm";
      arch = "x86_64";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "local-vm";
      users = {
        "dudeofawesome" = import ../../users/dudeofawesome { };
      };
    in
    lib.nixosSystem {
      system = "${arch}-${os}";
      specialArgs = {
        inherit
          inputs
          hostname
          arch
          os
          owner
          machine-class
          ;
      };
      modules = [
        packageOverlays

        ./${hostname}
        { _module.args.users = users; }

        sops.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager = import ../../modules/host-home-manager.nix {
            inherit
              inputs

              users
              hostname
              os
              owner
              machine-class

              nix-vscode-extensions
              dudeofawesome_dotfiles
              upaymeifixit_dotfiles
              ;
          };
        }
      ];
    };

  monongahela =
    let
      hostname = "monongahela";
      arch = "x86_64";
      os = "linux";
      owner = "dudeofawesome";
      machine-class = "scratch";
      users = {
        "dudeofawesome" = import ../../users/dudeofawesome { };
      };
    in
    lib.nixosSystem {
      system = "${arch}-${os}";
      specialArgs = {
        inherit
          inputs
          hostname
          arch
          os
          owner
          machine-class
          ;
      };
      modules = [
        packageOverlays

        ./${hostname}
        { _module.args.users = users; }

        sops.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager = import ../../modules/host-home-manager.nix {
            inherit
              inputs

              users
              hostname
              os
              owner
              machine-class

              nix-vscode-extensions
              dudeofawesome_dotfiles
              upaymeifixit_dotfiles
              ;
          };
        }
      ];
    };
}
