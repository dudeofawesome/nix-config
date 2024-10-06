{ pkgs, lib, config, ... }:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.DanPristupov.Fork" = {
        defaultSourceFolder = "/Users/${config.home.username}/git";
        NSNavLastRootDirectory = "~/git";

        # rebase + stash & apply
        pullSheetRebase = true;
        pullSheetStashAndReapply = true;
        rebaseSheetAutostash = true;
        checkoutBranchSheetStashAndReapply = true;
        deleteStashAfterApply = false;
        trackBranchSheetStashAndReapply = true;

        fetchAllTags = true;
        fetchSheetFetchAllRemotes = false;
        createBranchSheetCheckout = true;

        diffIgnoreWhitespaces = true;
        diffShowHiddenSymbols = true;
      };
    };
  };
}
