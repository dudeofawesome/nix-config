{ os, ... }:
{
  imports = [
    (if (builtins.pathExists ./default.${os}.nix) then ./default.${os}.nix else { })

    ./editors.nix
    ./miscellaneous.nix
    ./nix.nix
    ./shells.nix
    ./sops.nix
  ];
}
