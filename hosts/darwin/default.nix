{ lib
, inputs
, usersModule
, packageOverlays
, ...
}: {
  crater-lake = inputs.darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
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
      packageOverlays
      ;
    hostname = "joshs-paciolan-laptop";
    arch = "aarch64";
    os = "darwin";
    owner = "josh";
    machine-class = "pc";
    users = usersModule.filterMap { josh = "joshuagibbs"; } usersModule.users;
  });
}
