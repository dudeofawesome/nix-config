{ pkgs, lib, config, owner, ... }: {
  environment = {
    systemPackages = with pkgs; [
      spice-vdagent
      phodav
    ];
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagent.enable = true;
    spice-autorandr.enable = true;
    spice-webdavd.enable = true;

    getty = {
      greetingLine = ''
        >>> Welcome to NixOS ${config.system.nixos.label} (\m) - \l
        >>> \n \4
      '';
      autologinUser =
        if (!config.services.xserver.desktopManager.gnome.enable) then
          lib.mkDefault owner
        else null;
    };
  };
}
