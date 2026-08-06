{ pkgs, ... }: {
  boot = {
    plymouth = {
      enable = true;

      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        # By default we would install all themes
        # (adi1090x-plymouth-themes.override {
        #   selected_themes = [ "rings" ];
        # })
        nixos-bgrt-plymouth
      ];

      # HiDPI
      # extraConfig = ''
      #   [Daemon]
      #   DeviceScale=1
      # '';
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
