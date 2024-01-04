{ pkgs, ... }: {
  imports = [ ./base.nix ];

  fonts = {
    # TODO: bring this back in to base.nix once [this issue](https://github.com/LnL7/nix-darwin/issues/752) is closed.
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      })
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      usbutils
    ];
  };

  services = {
    automatic-timezoned.enable = true;
    vscode-server.enable = true;
  };

  console = {
    # TODO: set custom console font
    #   https://github.com/Anomalocaridid/dotfiles/blob/fcd37335d9799a9efd5e0c9aacdd12ab6283a259/modules/theming.nix#L4
    # enable setting TTY keybaord layout
    useXkbConfig = true;
  };
}
