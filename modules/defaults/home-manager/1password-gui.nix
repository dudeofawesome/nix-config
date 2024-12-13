{ ... }:
{
  config = {
    programs._1password-gui = {
      extraConfig = {
        "security.authenticatedUnlock.appleTouchId" = true;
        "security.authenticatedUnlock.enabled" = true;
        "security.autolock.minutes" = 1;
        "security.holdToggleReveal" = true;

        "keybinds.quickAccess" = "Alt+CommandOrControl+[\\]\\";
        "keybinds.autoFill" = "";

        "privacy.checkHibp" = true;
        "developers.cliSharedLockState.enabled" = true;

        "sshAgent.storeKeyTitles" = true;
        "sshAgent.storeSshKeyTitlesResponseGiven" = true;
        "sshAgent.enabled" = true;
        "sshAgent.sshAuthorizatonModel" = "application";
        "sidebar.showCategories" = true;

        "app.SkipArchiveAlert" = true;
        "app.nearbyItemsEnabled" = true;
        "sshAgent.commitSigningBannerDismissed" = true;
        "browsers.extension.enabled" = true;

        "passwordGenerator.type" = "password-generator-menu-entry-type-random-password";
        "passwordGenerator.size.words" = 8;
        "passwordGenerator.size.characters" = 16;
        "passwordGenerator.size.pin" = 4;
        "passwordGenerator.separatorType" = "password-generator-menu-entry-separator-spaces";
        "passwordGenerator.capitalize" = true;
        "passwordGenerator.includeSymbols" = true;

        "privacy.mapsEnabled" = true;
        "advanced.EnableDebuggingTools" = true;
        "itemDetails.showWebFormDetails" = true;
      };
    };
  };
}
