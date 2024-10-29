{ inputs
, hostname
, arch
, os
, owner
, machine-class
, users
, ...
}: {
  useGlobalPkgs = true;
  useUserPackages = true;

  users = builtins.mapAttrs (key: val: val.home-manager) users;
  extraSpecialArgs = {
    inherit
      hostname
      arch
      os
      owner
      machine-class
      users
      ;
  };
  sharedModules = [
    inputs.sops.homeManagerModules.sops
    inputs._1password-shell-plugins.hmModules.default
    ./configurable/home-manager/default.nix
  ];
}
