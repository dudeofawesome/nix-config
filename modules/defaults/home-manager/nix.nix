{ ... }: {
  home.file.nix-config = {
    target = ".config/nixpkgs/config.nix";
    # TODO: make this a real attrset
    text = ''
      {
        allowUnfree = true;
      }
    '';
  };
}
