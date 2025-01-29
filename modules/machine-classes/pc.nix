{
  pkgs,
  pkgs-unstable,
  lib,
  os,
  ...
}:
with lib;
let
  doa-lib = import ../../lib;
in
{
  imports = [
    (doa-lib.try-import ./pc.${os}.nix)
    ../defaults/containers/k8s/user-utils.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      docker
      mitmproxy
      pkgs-unstable.moonlight-qt
      watch
    ];
  };
}
