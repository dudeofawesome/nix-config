{ pkgs }: {
  environment = {
    systemPackages = with pkgs; [
      qmk
      qmk_hid
      keymapviz
    ];
  };

  hardware.keyboard.qmk.enable = true;
}
