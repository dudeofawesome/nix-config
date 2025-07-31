{ ... }:
{
  programs.finicky = {
    enable = true;
    settings = ''
      const zoom_path = ``;
      ${builtins.readFile ./finicky.js}
    '';
  };
}
