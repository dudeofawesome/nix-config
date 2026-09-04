{
  pkgs,
  lib,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    bcachefs-tools
  ];

  boot.supportedFilesystems = [ "bcachefs" ];
}
