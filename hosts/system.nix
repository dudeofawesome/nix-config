# This is an OS & distribution agnostic file that is used as the root of a
# system configuration. It defines the system based on a series of parameters
# that are passed to it.

{ inputs
, lib
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
    (if (builtins.pathExists ./${distro}/${hostname}/disko.nix) then ./${distro}/${hostname}/disko.nix else { })
    ../modules/machine-classes/${machine-class}.nix
    ../modules/presets/os/base
    (if (builtins.pathExists ../users/${owner}/os/default.nix) then ../users/${owner}/os/default.nix else { })
    (if (builtins.pathExists ../users/${owner}/os/${os}.nix) then ../users/${owner}/os/${os}.nix else { })
    ../modules/defaults/auth

    (if (os == "linux") then inputs.disko.nixosModules.disko else { })
    (if (os == "linux") then inputs.sops.nixosModules.sops else { })
    (if (os == "linux") then inputs.vscode-server.nixosModules.default else { })

    inputs.home-manager.${distroModules}.home-manager
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
