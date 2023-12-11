{ ... }: {
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      # TODO: disable this for enhanced security
      editor = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
