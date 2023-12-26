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
  kings-canyon = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      packageOverlays
      nix-vscode-extensions
      dudeofawesome_dotfiles
      upaymeifixit_dotfiles
      ;
    hostname = "kings-canyon";
    arch = "x86_64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "server";
    users = {
      "dudeofawesome" = import ../../users/dudeofawesome { };
    };
  });

  badlands-vm = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      packageOverlays
      nix-vscode-extensions
      dudeofawesome_dotfiles
      upaymeifixit_dotfiles
      ;
    hostname = "badlands-vm";
    arch = "x86_64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "local-vm";
    users = {
      "dudeofawesome" = import ../../users/dudeofawesome { };
    };
  });

  monongahela = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      packageOverlays
      nix-vscode-extensions
      dudeofawesome_dotfiles
      upaymeifixit_dotfiles
      ;
    hostname = "monongahela";
    arch = "x86_64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "scratch";
    users = {
      "dudeofawesome" = import ../../users/dudeofawesome { };
    };
  });
}
