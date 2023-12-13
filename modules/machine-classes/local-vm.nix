{ pkgs, config, users, ... }: {
  environment = {
    systemPackages = with pkgs; [
      spice-vdagent
      phodav
    ];
  };

  services = {
    qemuGuest.enable = true;

    getty = {
      greetingLine = ''
        >>> Welcome to NixOS ${config.system.nixos.label} (\m) - \l
        >>> \n \4
      '';
      autologinUser = builtins.elemAt (builtins.attrNames users) 0;
    };
  };
}
