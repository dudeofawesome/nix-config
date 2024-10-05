{ pkgs, lib, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.rouge41.middleClick" = {
        needClick = false;
        fingers = 4;
      };
    };

    home = {
      activation.middleclick = ''
        PATH="/usr/bin:$PATH" $DRY_RUN_CMD osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/MiddleClick.app", hidden:true}'
      '';
    };
  };
}
