{ pkgs, lib, config, ... }: {
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      NSDocumentSaveNewDocumentsToCloud = false;
    };

    "com.apple.finder" = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;

      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      # Use columns view
      FXPreferredViewStyle = "clmv";

      SidebarWidth = 158;

      ShowRemovableMediaOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = true;

      NewWindowTargetPath = "file://${config.home.homeDirectory}/";
    };
  };
}
