# This is an OS & distribution agnostic file that is used as the root of a
# system configuration. It defines the system based on a series of parameters
# that are passed to it.

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
      users
      ;
  };
  modules = [
    packageOverlays

    ./${distro}/${hostname}
    (if (os == "linux") then ./${distro}/${hostname}/hardware-configuration.nix else { })
    ./${distro}/configuration.nix
    ../modules/machine-classes/base.nix
    ../modules/machine-classes/${machine-class}.nix
    (if (builtins.pathExists ../users/${owner}/os/${os}.nix) then ../users/${owner}/os/${os}.nix else { })
    ../modules/auth.nix

    sops.nixosModules.sops
    (if (os == "linux") then vscode-server.nixosModules.default else { })

    home-manager.${distroModules}.home-manager
    {
      home-manager = import ../modules/host-home-manager.nix {
        inherit
          inputs

          hostname
          arch
          os
          owner
          machine-class
          users
          ;
      };
    }
  ];
}
