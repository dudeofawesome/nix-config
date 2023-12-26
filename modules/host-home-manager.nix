{ inputs
, users
, hostname
, os
, owner
, machine-class
, nix-vscode-extensions
, dudeofawesome_dotfiles
, upaymeifixit_dotfiles
, ...
}: {
  useGlobalPkgs = true;
  useUserPackages = true;

  users = builtins.mapAttrs (key: val: val.home-manager) users;
  extraSpecialArgs = {
    inherit
      nix-vscode-extensions
      dudeofawesome_dotfiles
      upaymeifixit_dotfiles
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
