{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.git-fork;
in
{
  options = {
    programs.git-fork = {
      enable = lib.mkEnableOption "Fork desktop app";

      package = lib.mkPackageOption pkgs "Git client" {
        default = [ "git-fork" ];
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          options = {
            defaultSourceFolder = lib.mkOption {
              type = lib.types.path;
              description = "Path to the default source folder";
              default = "${config.home.homeDirectory}/git";
            };

            # rebase + stash & apply
            rebaseOnPull = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to rebase on pull";
              default = true;
            };
            stashAndReapplyOnPull = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to stash & reapply on pull";
              default = true;
            };
            stashandReapplyOnRebase = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to stash & reapply on rebase";
              default = true;
            };
            stashAndReapplyOnCheckout = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to stash & reapply on checkout";
              default = true;
            };
            deleteStashAfterApply = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to delete stash after apply";
              default = false;
            };
            stashAndReapplyOnTrackBranch = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to stash & reapply on tracking branch";
              default = true;
            };

            # fetching
            fetchAllTags = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to fetch all tags";
              default = true;
            };
            fetchAllRemotes = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to fetch all remotes";
              default = false;
            };
            checkoutBranchOnCreate = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to checkout branch on create";
              default = true;
            };
            fetchRemotesAutomatically = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to fetch remotes periodically automatically";
              default = false;
            };

            # diff
            diffIgnoreWhitespaces = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to ignore whitespace in diffs";
              default = true;
            };
            diffShowHiddenSymbols = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to show hidden symbols in diffs";
              default = true;
            };
          };
        };
        default = { };
        description = "Configuration for Fork.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    targets.darwin = {
      defaults."com.DanPristupov.Fork" = {
        defaultSourceFolder = cfg.settings.defaultSourceFolder;
        NSNavLastRootDirectory = cfg.settings.defaultSourceFolder;

        # rebase + stash & apply
        pullSheetRebase = cfg.settings.rebaseOnPull;
        pullSheetStashAndReapply = cfg.settings.stashAndReapplyOnPull;
        rebaseSheetAutostash = cfg.settings.stashandReapplyOnRebase;
        checkoutBranchSheetStashAndReapply = cfg.settings.stashAndReapplyOnCheckout;
        deleteStashAfterApply = cfg.settings.deleteStashAfterApply;
        trackBranchSheetStashAndReapply = cfg.settings.stashAndReapplyOnTrackBranch;

        # fetching
        fetchAllTags = cfg.settings.fetchAllTags;
        fetchSheetFetchAllRemotes = cfg.settings.fetchAllRemotes;
        createBranchSheetCheckout = cfg.settings.checkoutBranchOnCreate;
        fetchRemotesAutomatically = cfg.settings.fetchRemotesAutomatically;

        # diff
        diffIgnoreWhitespaces = cfg.settings.diffIgnoreWhitespaces;
        diffShowHiddenSymbols = cfg.settings.diffShowHiddenSymbols;
      };
    };
  };
}
