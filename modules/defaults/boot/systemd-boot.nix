{ lib, config, ... }:
{
  config = lib.mkIf config.boot.loader.systemd-boot.enable {
    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot = {
        # TODO: disable this for enhanced security
        editor = true;
        # Prevents boot partition from running out of disk space.
        configurationLimit = 50;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
