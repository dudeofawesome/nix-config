{ pkgs, ... }: {
  imports = [
    ../configurable/hosts.darwin.nix
  ];

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
