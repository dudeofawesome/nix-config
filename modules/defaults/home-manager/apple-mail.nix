{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults."com.apple.mail" = {
      # Set left swipe to archive
      SwipeAction = 1;

      "NSToolbar Configuration MainWindow" = {
        "TB Item Identifiers" = [
          "saveSearch:"
          "toggleMessageListFilter:"
          "SeparatorToolbarItem"
          "checkNewMail:"
          "showComposeWindow:"
          "NSToolbarFlexibleSpaceItem"
          "archiveMessages:"
          "deleteMessages:"
          "reply_replyAll_forward"
          "FlaggedStatus"
          "toggleAllHeaders:"
          "NSToolbarFlexibleSpaceItem"
          "Search"
        ];
      };
    };
  };
}
