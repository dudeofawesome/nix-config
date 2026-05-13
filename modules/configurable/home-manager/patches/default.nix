{ ... }:
let
  nixFiles = builtins.filter (
    name: name != "default.nix" && (builtins.match ".*\\.nix" name != null)
  ) (builtins.attrNames (builtins.readDir ./.));
in
{
  imports = map (name: ./. + "/${name}") nixFiles;
}
