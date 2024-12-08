{
  pkgs,
  lib,
  osConfig,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  doa-lib = import ../../../lib;
  cask-installed = doa-lib.cask-installed { inherit osConfig; };
in
{
  config = {
    home.file-json._1password-gui = {
      enable = isDarwin && (cask-installed "1password");
      target = "Library/Group Containers/2BUA8C4S2C.com.1password/Library/Application Support/1Password/Data/settings/settings.json";
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
        "app.defaultVaultForSaving" = "{\"VaultReference\":{\"vault_uuid\":\"rnjzxcl63xsr2niiycqwpmy26y\",\"account_uuid\":\"TWLWKGXBYVAUPAP2VKFNNGUFHQ\"}}";
        "app.nearbyItemsEnabled" = true;
        "sshAgent.commitSigningBannerDismissed" = true;
        "browsers.extension.enabled" = true;
        "ui.quickAccess.collection" = "45qc7o7ua53ez6tqhwvqaxdvge";

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
