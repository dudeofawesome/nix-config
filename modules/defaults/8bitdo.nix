# Fix for using Xinput mode on 8bitdo Ultimate C controller
# Inspired by https://aur.archlinux.org/packages/8bitdo-ultimate-controller-udev
{
  config,
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
{
  # Udev rules to start or stop systemd service when controller is connected or disconnected
  services.udev.extraRules =
    with builtins;
    concatStringsSep "\n" (
      map
        (
          prodId:
          (concatStringsSep "\n" (
            map
              (
                cmd:
                (concatStringsSep ", " [
                  ''SUBSYSTEM=="usb"''
                  ''ATTR{idVendor}=="2dc8"''
                  ''ATTR{idProduct}=="${prodId}"''
                  ''ATTR{manufacturer}=="8BitDo"''
                  ''RUN+="${pkgs.systemd}/bin/systemctl ${cmd} 8bitdo-ultimate-xinput@2dc8:${prodId}"''
                ])
              )
              [
                "start"
                "stop"
              ]
          ))
        )
        # Product ID may vary depending on your controller model.
        # Find your product id using 'lsusb' with the controller powered on.
        [ "3106" ]
    );

  # TODO: how to do this with the [kernel driver](https://github.com/paroj/xpad)?
  # Systemd service which starts xboxdrv in xbox360 mode
  # systemd.services."8bitdo-ultimate-xinput@" = {
  #   unitConfig.Description = "8BitDo Ultimate Controller XInput mode xboxdrv daemon";
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${lib.getExe pkgs-unstable.xboxdrv} --mimic-xpad --silent --type xbox360 --device-by-id %I --force-feedback";
  #   };
  # };
}
