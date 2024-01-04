{ lib
, inputs
, nixpkgs
, home-manager
, sops
, vscode-server
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
      vscode-server
      packageOverlays
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
      vscode-server
      packageOverlays
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
      vscode-server
      packageOverlays
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

  soto-server = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      packageOverlays
      ;
    hostname = "soto-server";
    arch = "x86_64";
    os = "linux";
    owner = "josh";
    machine-class = "server";
    users = {
      "josh" = import ../../users/josh { };
    };
  });
}
