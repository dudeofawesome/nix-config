{ lib
, inputs
, nixpkgs
, home-manager
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
    users = {
      "dudeofawesome" = import ../../users/dudeofawesome { };
    };
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
    users = {
      "lorleans" = import ../../users/dudeofawesome { };
    };
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
    users = {
      "joshuagibbs" = import ../../users/josh { };
    };
  });
}
