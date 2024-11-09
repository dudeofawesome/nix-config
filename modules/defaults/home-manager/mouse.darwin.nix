{ machine-class, owner, os, pkgs, lib, ... }: {
  targets.darwin.defaults = {
    NSGlobalDomain = {
      AppleShowScrollBars = "WhenScrolling";

      AppleEnableSwipeNavigateWithScrolls = false;
      AppleEnableMouseSwipeNavigateWithScrolls = true;

      "com.apple.mouse.scaling" = "0.875";
      "com.apple.trackpad.scaling" = "1.5";
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadFiveFingerPinchGesture = 2;
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadThreeFingerHorizSwipeGesture = 1;
      TrackpadThreeFingerTapGesture = 0;
      TrackpadThreeFingerVertSwipeGesture = 1;
    };

    dock = {
      showAppExposeGestureEnabled = true;
      showMissionControlGestureEnabled = true;
    };

    NSGlobalDomain = {
      "com.apple.trackpad.threeFingerHorizSwipeGesture" = 1;
      "com.apple.AppleMultitouchTrackpad.TrackpadFourFingerHorizSwipeGesture" = 2;
      "com.apple.AppleMultitouchTrackpad.TrackpadFourFingerVertSwipeGesture" = 2;
      "com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerHorizSwipeGesture" = true;
      "com.apple.AppleMultitouchTrackpad.TrackpadThreeFingerVertSwipeGesture" = true;
    };
  };
}
