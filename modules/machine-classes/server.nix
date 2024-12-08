{ pkgs, os, ... }:
let
  doa-lib = import ../../lib;
in
{
  imports = [
    (doa-lib.try-import ./server.${os}.nix)
  ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      lynx
      ncdu
    ];
  };
}
