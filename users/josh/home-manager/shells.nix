{ pkgs, ... }:
{
  programs = {
    fish.plugins =
      with pkgs.fishPlugins;
      map (pkg: { inherit (pkg) name src; }) [
        nvm-fish
      ];
    atuin.enable = true;
  };
}
