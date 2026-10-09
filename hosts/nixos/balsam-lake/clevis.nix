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
        # Enroll this machine after installing and enabling Secure Boot:
        # clevis encrypt tpm2 '{"pcr_ids":"7"}' < /root/bcachefs-password
        # Save the result as clevis.jwe beside this file and stage it in Git.
        # Until then, boot uses the recovery-passphrase prompt.
        devices = lib.optionalAttrs (builtins.pathExists ./clevis.jwe) {
          ${config.fileSystems."/".device}.secretFile = builtins.path {
            path = ./clevis.jwe;
            name = "balsam-lake-clevis.jwe";
          };
        };
      };
    };
  };
}
