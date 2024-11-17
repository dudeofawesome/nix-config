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
  doa-lib = import ../lib;
  distro = { "linux" = "nixos"; "darwin" = "darwin"; }."${os}";
  distroModules = "${distro}Modules";

  args = {
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
in
{
  system = "${arch}-${os}";
  specialArgs = args;
  modules = [
    packageOverlays

    ./${distro}/${hostname}
    (if (os == "linux") then ./${distro}/${hostname}/hardware-configuration.nix else { })
    (doa-lib.try-import ./${distro}/${hostname}/disko.nix)
    ../modules/machine-classes/${machine-class}.nix
    ../modules/presets/os/base
    (doa-lib.try-import ../users/${owner}/os/default.nix)
    (doa-lib.try-import ../users/${owner}/os/${os}.nix)
    ../modules/defaults/auth

    (if (os == "linux") then inputs.disko.nixosModules.disko else { })
    (if (os == "linux") then inputs.vscode-server.nixosModules.default else { })

    inputs.sops.${distroModules}.sops
    inputs.home-manager.${distroModules}.home-manager
    (import ../modules/host-home-manager.nix args)
  ];
}
