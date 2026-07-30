# https://wiki.nixos.org/wiki/Bcachefs#Generate_bcachefs_enabled_installation_media
{ pkgs, ... }: {
  imports = [ ../../../modules/defaults/fs/bcachefs.nix ];

  # Required as a workaround for bug
  # https://github.com/NixOS/nixpkgs/issues/32279
  environment.systemPackages = [ pkgs.keyutils ];
  # boot.supportedFilesystems = [ "bcachefs" ];
}
