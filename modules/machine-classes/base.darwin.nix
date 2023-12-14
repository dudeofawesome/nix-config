{ pkgs, ... }: {
  imports = [ ./base.nix ];

  fonts = {
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      })
    ];
  };
}
