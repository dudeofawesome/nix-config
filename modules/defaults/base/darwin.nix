{ pkgs, ... }: {
  imports = [
    ../../configurable/hosts.darwin.nix
  ];

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      })
    ];
  };
}
