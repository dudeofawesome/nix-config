{ ... }: {
  nix = {
    linux-builder = {
      enable = true;
      maxJobs = 10;
    };
  };

  # Auto-upgrade daemon
  services.nix-daemon.enable = true;
}
