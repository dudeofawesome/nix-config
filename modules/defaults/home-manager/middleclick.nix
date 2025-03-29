{ pkgs, lib, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."art.ginzburg.MiddleClick" = {
        needClick = false;
        fingers = 4;
        allowMoreFingers = true;
      };
    };

    home = {
      activation.middleclick = ''
        run --quiet /usr/bin/osascript -e '
          tell application "System Events" to make login item at end ¬
            with properties {path:"/Applications/MiddleClick.app", hidden:true}
        '
      '';
    };
  };
}
