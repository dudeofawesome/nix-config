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

    os = "darwin";
  };
in
{
  crater-lake = inputs.darwin.lib.darwinSystem (import ../system.nix ({
    hostname = "crater-lake";
    arch = "aarch64";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  } // base));

  badlands = inputs.darwin.lib.darwinSystem (import ../system.nix ({
    hostname = "badlands";
    arch = "aarch64";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap { dudeofawesome = "lorleans"; } usersModule.users;
  } // base));

  joshs-paciolan-laptop = inputs.darwin.lib.darwinSystem (import ../system.nix ({
    hostname = "joshs-paciolan-laptop";
    arch = "aarch64";
    owner = "josh";
    machine-class = "pc";
    users = usersModule.filterMap { josh = "joshuagibbs"; } usersModule.users;
  } // base));
}
