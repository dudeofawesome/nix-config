# This is an OS & distribution agnostic file that is used as the root of a
# system configuration. It defines the system based on a series of parameters
# that are passed to it.

{
  inputs,
  lib,
  packageOverlays,
  systemlessSpecialArgs,
  hostname,
  arch,
  os,
  owner,
  machine-class,
  users,
}:
let
  doa-lib = import ../lib;
  distro =
    {
      "linux" = "nixos";
      "darwin" = "darwin";
    }
    ."${os}";
  distroModules = "${distro}Modules";
  system = "${arch}-${os}";

  specialArgs = {
    # TODO; get rid of this
    nixos-raspberrypi = inputs.nixos-raspberrypi;

    inherit
      inputs

      doa-lib

      hostname
      arch
      os
      owner
      machine-class
      users
      ;
  }
  // (systemlessSpecialArgs system);
in
{
  inherit system specialArgs;
  modules = lib.flatten [
    packageOverlays

    ./${distro}/${hostname}
    (doa-lib.try-import ./${distro}/${hostname}/hardware-configuration.nix)
    (doa-lib.try-import ./${distro}/${hostname}/disko.nix)
    ../modules/machine-classes/${machine-class}.nix
    ../modules/presets/os/base
    (doa-lib.try-import ../users/${owner}/os/default.nix)
    (doa-lib.try-import ../users/${owner}/os/${os}.nix)
    ../modules/defaults/auth

    (lib.optionals (os == "linux") [
      inputs.disko.nixosModules.disko
      inputs.vscode-server.nixosModules.default
    ])

    (lib.optional (os == "darwin") inputs.determinate.darwinModules.default)

    inputs.sops.${distroModules}.sops
    inputs.home-manager.${distroModules}.home-manager
    (import ../modules/host-home-manager.nix specialArgs)
  ];
}
