{ lib
, inputs
, usersModule
, packageOverlays
, ...
}:
let
  base = {
    inherit
      inputs
      lib
      packageOverlays
      ;

    os = "linux";
  };
in
{
  kings-canyon = lib.nixosSystem (import ../system.nix ({
    hostname = "kings-canyon";
    arch = "x86_64";
    owner = "dudeofawesome";
    machine-class = "server";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  badlands-vm = lib.nixosSystem (import ../system.nix ({
    hostname = "badlands-vm";
    arch = "aarch64";
    owner = "dudeofawesome";
    machine-class = "local-vm";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  monongahela = lib.nixosSystem (import ../system.nix ({
    hostname = "monongahela";
    arch = "x86_64";
    owner = "dudeofawesome";
    machine-class = "server";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  haleakala = lib.nixosSystem (import ../system.nix ({
    hostname = "haleakala";
    arch = "x86_64";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  haleakala-sim = lib.nixosSystem (import ../system.nix ({
    hostname = "haleakala-sim";
    arch = "aarch64";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  soto-server = lib.nixosSystem (import ../system.nix ({
    hostname = "soto-server";
    arch = "x86_64";
    owner = "josh";
    machine-class = "server";
    users = usersModule.filterMap [ "josh" ] usersModule.users;
  } // base));
}
