{ lib, ... }: {
  nix = {
    linux-builder = {
      enable = true;
      maxJobs = lib.mkDefault 10;
    };
  };

  # Auto-upgrade daemon
  services.nix-daemon.enable = true;
}
