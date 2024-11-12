{ os, ... }:
let doa-lib = import ../../../lib; in
{
  imports = [
    (doa-lib.try-import ./default.${os}.nix)

    ./editors.nix
    ./miscellaneous.nix
    ./nix.nix
    ./shells.nix
    ./sops.nix
  ];
}
