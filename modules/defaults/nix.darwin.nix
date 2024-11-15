{ lib, ... }: {
  nix = {
    linux-builder = {
      enable = lib.mkDefault true;
      maxJobs = lib.mkDefault 10;
    };
  };

  # Auto-upgrade daemon
  services.nix-daemon.enable = lib.mkDefault true;
}
