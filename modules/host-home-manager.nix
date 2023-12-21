{ inputs
, users
, nix-vscode-extensions
, dudeofawesome_dotfiles
, upaymeifixit_dotfiles
, ...
}: {
  useGlobalPkgs = true;
  useUserPackages = true;

  users = builtins.mapAttrs (key: val: val.settings) users;
  extraSpecialArgs = {
    inherit
      nix-vscode-extensions
      dudeofawesome_dotfiles
      upaymeifixit_dotfiles
      ;
  };
}
