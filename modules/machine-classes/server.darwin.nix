{ pkgs, lib, os, ... }: with lib; {
  homebrew = {
    casks = [
      "iterm2"
      "keka"
      "sublime-text"
    ];
    masApps = {
      "Xcode" = 497799835;
    };
  };
}
