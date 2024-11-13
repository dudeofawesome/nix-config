{ pkgs, lib, os, ... }: with lib; {
  homebrew = {
    casks = [
      "keka"
      "sublime-text"
    ];
    masApps = {
      "Xcode" = 497799835;
    };
  };
}
