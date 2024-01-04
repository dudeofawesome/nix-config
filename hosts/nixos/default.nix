{ lib
, inputs
, nixpkgs
, home-manager
, usersModule
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
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
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
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
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
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
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
    users = usersModule.filterMap [ "josh" ] usersModule.users;
  });
}
