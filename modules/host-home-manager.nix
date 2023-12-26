{ inputs
, users
, hostname
, os
, owner
, machine-class
, ...
}: {
  useGlobalPkgs = true;
  useUserPackages = true;

  users = builtins.mapAttrs (key: val: val.home-manager) users;
  extraSpecialArgs = {
    inherit
      hostname
      os
      owner
      machine-class
      ;
  };
  sharedModules = [
    inputs.sops.homeManagerModules.sops
  ];
}
