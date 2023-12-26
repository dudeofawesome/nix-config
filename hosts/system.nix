{ inputs
, lib
, nixpkgs
, home-manager
, sops
, packageOverlays
, dudeofawesome_dotfiles
, upaymeifixit_dotfiles
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
  modules = "${distro}Modules";
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

    home-manager.${modules}.home-manager
    {
      home-manager = import ../modules/host-home-manager.nix {
        inherit
          inputs

          users
          hostname
          os
          owner
          machine-class

          dudeofawesome_dotfiles
          upaymeifixit_dotfiles
          ;
      };
    }
  ];
}
