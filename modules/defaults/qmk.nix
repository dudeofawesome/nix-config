{ pkgs-unstable }:
{
  environment = {
    systemPackages = with pkgs-unstable; [
      qmk
      qmk_hid
      keymapviz
    ];
  };

  hardware.keyboard.qmk.enable = true;
}
