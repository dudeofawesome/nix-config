{ machine-class, owner, os, pkgs, lib, ... }: {
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      AppleSpacesSwitchOnActivate = true;
      NSQuitAlwaysKeepsWindows = 1;
    };

    "com.apple.dock" = {
      mru-spaces = false; # don't automatically rearrange spaces
      expose-group-by-app = false;

      wvous-tl-corner = 4; # Desktop
      wvous-br-corner = 14; # Quick Note
    };
  };
}
