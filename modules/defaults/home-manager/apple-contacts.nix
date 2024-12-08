{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults = {
      NSGlobalDomain = {
        # First name first
        NSPersonNameDefaultDisplayNameOrder = 1;

        # Prefer nicknames
        NSPersonNameDefaultShouldPreferNicknamesPreference = 1;

        # Short name only
        NSPersonNameDefaultShortNameEnabled = 1;
        NSPersonNameDefaultShortNameFormat = 3;
      };

      "com.apple.AddressBook" = {
        ABNameSortingFormat = "sortingFirstName sortingLastName";
        ABBirthDayVisible = true;
      };
    };
  };
}
