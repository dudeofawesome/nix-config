{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    clevis
  ];

  boot = {
    initrd = {
      clevis = {
        enable = true;
        devices.${config.fileSystems."/".device}.secretFile = ./clevis.jwe;
      };

      # enable single-entry decrypt
      systemd = {
        services =
          lib.genAttrs
            [
              "unlock-bcachefs-home"
              "unlock-bcachefs-nix"
              "unlock-bcachefs-tmp"
            ]
            (_: {
              # All subvolumes share the root filesystem's encryption key. Skip
              # their generated unlock attempts so they cannot race its mount.
              serviceConfig.ExecCondition = lib.mkForce (lib.getExe' pkgs.coreutils "false");
            });
      };
    };
  };
}
