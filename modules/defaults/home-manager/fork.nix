{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.DanPristupov.Fork" = {
        pullSheetRebase = true;
        pullSheetStashAndReapply = true;
        rebaseSheetAutostash = true;
        fetchAllTags = true;
        fetchSheetFetchAllRemotes = false;
        deleteStashAfterApply = true;
        defaultSourceFolder = "/Users/${config.home.username}/git";
      };
    };
  };
}
