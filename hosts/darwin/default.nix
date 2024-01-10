{ lib
, inputs
, nixpkgs
, usersModule
, packageOverlays
, ...
}: {
  crater-lake = inputs.darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      packageOverlays
      ;
    hostname = "crater-lake";
    arch = "aarch64";
    os = "darwin";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  });

  badlands = inputs.darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      packageOverlays
      ;
    hostname = "badlands";
    arch = "aarch64";
    os = "darwin";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap { dudeofawesome = "lorleans"; } usersModule.users;
  });

  joshs-paciolan-laptop = inputs.darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      packageOverlays
      ;
    hostname = "joshs-paciolan-laptop";
    arch = "aarch64";
    os = "darwin";
    owner = "josh";
    machine-class = "pc";
    users = usersModule.filterMap { joshuagibbs = "josh"; } usersModule.users;
  });
}
