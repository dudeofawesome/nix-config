{ pkgs, lib, ... }:
{
  targets.darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    defaults."com.rouge41.middleClick" = {
      needClick = false;
      fingers = 4;
    };
  };

  home = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    activation.middleclick = ''
      PATH="/usr/bin:$PATH" $DRY_RUN_CMD osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/MiddleClick.app", hidden:true}'
    '';
  };
}
