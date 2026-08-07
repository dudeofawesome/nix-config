{
  lib,
  config,
  owner,
  ...
}:
{
  services = {
    hardware.openrgb = {
      enable = true;
      # package = pkgs.openrgb.withPlugins (with pkgs; [ openrgb-plugin-effects ]);
      zone_sizes = ./openrgb-sizes.ors;

      startupProfile = "/home/dudeofawesome/.config/openrgb/orange";
    };

    ratbagd.enable = true;

    udev.extraRules = ''
      # Prevent mouse movement from waking the system through the Logitech Lightspeed receiver.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c539", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    '';
  };

  systemd.services.openrgb-profile = {
    description = "Apply an OpenRGB profile";
    requires = [ "openrgb.service" ];
    after = [
      "openrgb.service"
      "systemd-hibernate.service"
      "systemd-hybrid-sleep.service"
      "systemd-suspend.service"
      "systemd-suspend-then-hibernate.service"
    ];
    wantedBy = [
      "hibernate.target"
      "hybrid-sleep.target"
      "multi-user.target"
      "suspend.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = owner;
      ExecStart = "${lib.getExe config.services.hardware.openrgb.package} --profile orange";
    };
  };
}
