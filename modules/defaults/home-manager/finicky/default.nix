{ ... }:
{
  programs.finicky = {
    enable = true;
    settings = builtins.readFile ./finicky.js;
  };
}
