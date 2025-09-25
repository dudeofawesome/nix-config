{ lib, ... }:
{
  programs.finicky = {
    enable = true;
    settings = lib.mkDefault (builtins.readFile ./finicky.js);
  };
}
