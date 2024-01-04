{ lib
, inputs
, nixpkgs
, home-manager
, usersModule
, sops
, vscode-server
, packageOverlays
, darwin
, ...
}: {
  crater-lake = darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      vscode-server
      packageOverlays
      ;
    hostname = "crater-lake";
    arch = "aarch64";
    os = "darwin";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap [ "dudeofawesome" ] usersModule.users;
  });

  badlands = darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      vscode-server
      packageOverlays
      ;
    hostname = "badlands";
    arch = "aarch64";
    os = "darwin";
    owner = "dudeofawesome";
    machine-class = "pc";
    users = usersModule.filterMap { dudeofawesome = "lorleans"; } usersModule.users;
  });

  joshs-paciolan-laptop = darwin.lib.darwinSystem (import ../system.nix {
    inherit
      inputs
      lib
      nixpkgs
      home-manager
      sops
      vscode-server
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
