{
  pkgs,
  lib,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    gwe
    nvidia-vaapi-driver
  ];

  boot = {
    kernelModules = [ "nvidia" ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = [ config.boot.kernelPackages.nvidia_x11.out ];
    extraPackages32 = [ config.boot.kernelPackages.nvidia_x11.lib32 ];
  };

  services = {
    xserver = lib.mkIf config.services.xserver.enable {
      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [ "nvidia" ];
      # Nvidia doesn't want to work well with Wayland
      displayManager.gdm.wayland = lib.mkIf config.services.xserver.displayManager.gdm.enable false;
    };
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement = {
      enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      finegrained = false;
    };

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = lib.mkDefault false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
