{
  pkgs,
  lib,
  config,
  ...
}:
{
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    NSGlobalDomain = {
      AppleShowAllExtensions = lib.mkDefault true;
      NSDocumentSaveNewDocumentsToCloud = lib.mkDefault false;
    };

    "com.apple.finder" = {
      AppleShowAllExtensions = lib.mkDefault true;
      AppleShowAllFiles = lib.mkDefault true;

      # When performing a search, search the current folder by default
      FXDefaultSearchScope = lib.mkDefault "SCcf";
      # Use columns view
      FXPreferredViewStyle = lib.mkDefault "clmv";

      SidebarWidth = lib.mkDefault 158;

      ShowRemovableMediaOnDesktop = lib.mkDefault true;
      ShowHardDrivesOnDesktop = lib.mkDefault false;
      ShowExternalHardDrivesOnDesktop = lib.mkDefault true;

      NewWindowTargetPath = lib.mkDefault "file://${config.home.homeDirectory}/";
    };
  };
}
