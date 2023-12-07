{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      spice-vdagent
    ];
  };

  services.qemuGuest.enable = true;
  virtualisation.qemu.guestAgent.enable = true;
}
