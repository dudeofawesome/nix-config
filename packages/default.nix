{ inputs, ... }:
inputs.eachSystem (
  { pkgs, ... }:
  {
    aerospace-swipe = import ./aerospace-swipe;
  }
)
