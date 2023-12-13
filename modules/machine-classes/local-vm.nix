{ pkgs, users, ... }: {
  environment = {
    systemPackages = with pkgs; [
      spice-vdagent
      phodav
    ];
  };

  services = {
    qemuGuest.enable = true;
    getty.autologinUser = builtins.elemAt (builtins.attrNames users) 0;
  };
}
