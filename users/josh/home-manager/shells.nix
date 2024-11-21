{ pkgs, ... }: {
  programs = {
    fish.plugins = with pkgs.fishPlugins; [
      nvm-fish
    ];
    atuin.enable = true;
  };
}
