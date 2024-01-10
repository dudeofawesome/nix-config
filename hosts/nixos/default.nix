{ lib
, inputs
, nixpkgs
, usersModule
, packageOverlays
, ...
}: {
  kings-canyon = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
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
      packageOverlays
      ;
    hostname = "badlands-vm";
    arch = "aarch64";
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
      packageOverlays
      ;
    hostname = "monongahela";
    arch = "x86_64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "scratch";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  });

  haleakala = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      packageOverlays
      ;
    hostname = "haleakala";
    arch = "x86_64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  });

  haleakala-sim = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      packageOverlays
      ;
    hostname = "haleakala-sim";
    arch = "aarch64";
    os = "linux";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  });

  soto-server = lib.nixosSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
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
