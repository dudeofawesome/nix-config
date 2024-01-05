{ inputs
, lib
, nixpkgs
, home-manager
, sops
, vscode-server
, packageOverlays
, hostname
, arch
, os
, owner
, machine-class
, users
, ...
}:
let
  distro = { "linux" = "nixos"; "darwin" = "darwin"; }."${os}";
  distroModules = "${distro}Modules";
in
{
  system = "${arch}-${os}";
  specialArgs = {
    inherit
      inputs
      hostname
      arch
      os
      owner
      machine-class
      ;
  };
  modules = [
    packageOverlays

    ./${distro}/${hostname}
    { _module.args.users = users; }

    sops.nixosModules.sops
    (if (os == "linux") then vscode-server.nixosModules.default else { })

    home-manager.${distroModules}.home-manager
    {
      home-manager = import ../modules/host-home-manager.nix {
        inherit
          inputs

          users
          hostname
          os
          owner
          machine-class
          ;
      };
    }
  ];
}
