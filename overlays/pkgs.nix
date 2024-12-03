inputs: system:
let
  args = {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  pkgs-stable = import inputs.nixpkgs-stable args;
  pkgs-unstable = import inputs.nixpkgs-unstable args;
}
