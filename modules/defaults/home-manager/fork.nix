{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    programs.git-fork = {
      enable = true;
    };

    targets.darwin = {
      defaults."com.DanPristupov.Fork" = {
        defaultSourceFolder = "${config.home.homeDirectory}/git";
        NSNavLastRootDirectory = "~/git";

        # rebase + stash & apply
        pullSheetRebase = true;
        pullSheetStashAndReapply = true;
        rebaseSheetAutostash = true;
        checkoutBranchSheetStashAndReapply = true;
        deleteStashAfterApply = false;
        trackBranchSheetStashAndReapply = true;

        # fetching
        fetchAllTags = true;
        fetchSheetFetchAllRemotes = false;
        createBranchSheetCheckout = true;
        fetchRemotesAutomatically = false;

        # diff
        diffIgnoreWhitespaces = true;
        diffShowHiddenSymbols = true;
      };
    };
  };
}
