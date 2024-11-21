{ pkgs, lib, config, ... }: {
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults = {
      "com.apple.dock" = {
        autohide = lib.mkDefault true;
        orientation = lib.mkDefault "bottom";
        showhidden = lib.mkDefault true;
        tilesize = lib.mkDefault 40;
        magnification = lib.mkDefault false;
        size-immutable = true;
        minimize-to-application = lib.mkDefault true;
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
        "${config.home.homeDirectory}/Downloads/" = {
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
