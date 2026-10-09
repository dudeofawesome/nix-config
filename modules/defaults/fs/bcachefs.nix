{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ../boot/bcachefs-unlock-once.nix ];

  environment.systemPackages = with pkgs; [
    bcachefs-tools
  ];

  boot.supportedFilesystems = [ "bcachefs" ];
}
