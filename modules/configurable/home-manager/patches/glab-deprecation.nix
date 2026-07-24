{
  inputs,
  lib,
  ...
}:
let
  deprecations = import "${inputs.home-manager}/modules/deprecations.nix";
  patchedLib = lib // {
    mkRemovedOptionModule =
      option: message:
      if
        option == [
          "programs"
          "glab"
          "enable"
        ]
      then
        { }
      else
        lib.mkRemovedOptionModule option message;
  };
in
{
  disabledModules = [ "deprecations.nix" ];
  imports = [ (deprecations { lib = patchedLib; }) ];
}
