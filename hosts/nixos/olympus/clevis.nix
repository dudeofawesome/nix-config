{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/defaults/clevis.nix
  ];

  boot = {
    initrd = {
      clevis = {
        devices.${config.fileSystems."/".device}.secretFile = builtins.path {
          path = ./clevis.jwe;
          name = "olympus-clevis.jwe";
        };
      };
    };
  };
}
