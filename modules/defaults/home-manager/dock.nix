{ pkgs, lib, ... }: {
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults = {
      "com.apple.dock" = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        tilesize = 40;
        magnification = false;
        size-immutable = true;
        minimize-to-application = true;
      };
    };

    programs.dock = {
      others = {
        # /Applications
        "/Applications/" = {
          fileType = "1";
          arrangement = "1";
          displayAs = "1";
          showAs = "2";
          arrangement2 = "1";
        };
        # ~/Downloads
        "/Users/'$(whoami)'/Downloads/" = {
          fileType = "2";
          arrangement = "1";
          displayAs = "0";
          showAs = "1";
          arrangement2 = "2";
        };
      };
    };
  };
}
