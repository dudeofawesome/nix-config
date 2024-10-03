{ pkgs, lib, ... }:
{
  home = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    activation.middleclick = ''
      PATH="/usr/bin:$PATH" $DRY_RUN_CMD osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/MiddleClick.app", hidden:true}'
      PATH="/usr/bin:$PATH" $DRY_RUN_CMD defaults write com.rouge41.middleClick fingers 4
    '';
  };
}
