{ pkgs, lib, ... }: {
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      AppleSpacesSwitchOnActivate = true;
      NSQuitAlwaysKeepsWindows = true;
      # use ctrl+cmd to drag windows from anywhere
      NSWindowShouldDragOnGesture = true;
    };

    "com.apple.dock" = {
      mru-spaces = false; # don't automatically rearrange spaces
      expose-group-by-app = false;

      wvous-tl-corner = 4; # Desktop
      wvous-br-corner = 14; # Quick Note
    };
  };
}
