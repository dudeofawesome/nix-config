{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults = {
      "ZoomChat" = {
        ZoomShowIconInMenuBar = "false";
        ZoomShouldShowSharingWithSplitView = "true";
      };
    };
  };
}
