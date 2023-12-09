{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      spice-vdagent
    ];
  };

  services.qemuGuest.enable = true;
}
