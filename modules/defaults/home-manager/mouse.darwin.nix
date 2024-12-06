{ ... }: {
  targets.darwin.defaults =
    let
      trackpads = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadCornerSecondaryClick = 0;
        USBMouseStopsTrackpad = 0;
        Dragging = 0;
        DragLock = 0;

        TrackpadScroll = true;
        TrackpadHorizScroll = 1;
        TrackpadMomentumScroll = true;

        TrackpadRotate = 1;
        TrackpadPinch = 1;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadThreeFingerTapGesture = 0;
        TrackpadThreeFingerVertSwipeGesture = 1;
        TrackpadThreeFingerHorizSwipeGesture = 1;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadThreeFingerDrag = false;
      };
    in
    {
      NSGlobalDomain = {
        AppleShowScrollBars = "WhenScrolling";

        AppleEnableSwipeNavigateWithScrolls = false;
        AppleEnableMouseSwipeNavigateWithScrolls = true;

        "com.apple.mouse.scaling" = "0.875";
        "com.apple.trackpad.scaling" = "1.5";
      };

      # Internal Trackpad
      "com.apple.AppleMultitouchTrackpad" = trackpads;
      # Magic Trackpad
      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = trackpads;

      # Magic Mouse
      "com.apple.driver.AppleBluetoothMultitouch.mouse" = {
        MouseVerticalScroll = true;
        MouseHorizontalScroll = true;
        MouseMomentumScroll = true;
        # TODO: validate these settings
        # MouseButtonDivision = 55;
        # MouseButtonMode = "OneButton";
        # MouseOneFingerDoubleTapGesture = 0;
        # MouseTwoFingerHorizSwipeGesture = 2;
        # MouseTwoFingerDoubleTapGesture = 3;
      };

      dock = {
        showAppExposeGestureEnabled = true;
        showMissionControlGestureEnabled = true;
      };
    };
}
