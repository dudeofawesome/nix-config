{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults."com.apple.Music" = {
      userWantsPlaybackNotifications = false;
      optimizeSongVolume = false;
      showStoreInSidebar = 1;
      losslessEnabled = true;
    };
  };
}
