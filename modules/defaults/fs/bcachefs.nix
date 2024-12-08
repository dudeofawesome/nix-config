{
  pkgs,
  lib,
  config,
  ...
}:
let
  # TODO: figure out a way to detect if a linuxPackage is LTS
  prefer_lts = false;
  lts_has_bcachefs = (builtins.compareVersions pkgs.linuxPackages.kernel.version "6.7") >= 0;
  kernelPackage =
    if (lts_has_bcachefs && prefer_lts) then pkgs.linuxPackages else pkgs.linuxPackages_latest;
in
{
  environment.systemPackages = with pkgs; [
    bcachefs-tools
  ];

  boot = {
    kernelPackages = lib.mkDefault kernelPackage;
    supportedFilesystems = [ "bcachefs" ];
  };
}
