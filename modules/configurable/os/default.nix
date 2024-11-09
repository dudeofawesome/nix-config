{ os, ... }: {
  imports = [
    (if (builtins.pathExists ./default.${os}.nix) then ./default.${os}.nix else { })
  ];
}
