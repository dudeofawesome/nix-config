{ os, ... }:
{
  imports = [ (if (builtins.pathExists ./keyboard.${os}.nix) then ./keyboard.${os}.nix else { }) ];
}
