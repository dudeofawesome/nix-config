{ pkgs-unstable }: {
  services.hardware.openrgb = {
    enable = true;
    package = pkgs-unstable.openrgb-with-all-plugins;
  };
}
