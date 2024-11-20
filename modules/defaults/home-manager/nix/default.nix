{ ... }: {
  nixpkgs.config = import ./config.nix;

  xdg.configFile.nixpkgs-config = {
    target = "nixpkgs/config.nix";
    source = ./config.nix;
  };
}
