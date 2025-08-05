inputs: system:
let
  lib = inputs.nixpkgs-linux-stable.lib;
  args = {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  pkgs-stable =
    if (lib.hasSuffix "-darwin" system) then
      (import inputs.nixpkgs-darwin-stable args)
    else
      (import inputs.nixpkgs-linux-stable args);
  pkgs-unstable = import inputs.nixpkgs-unstable args;
}
