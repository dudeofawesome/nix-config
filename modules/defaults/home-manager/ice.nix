{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.jordanbaird.Ice" = {
        AutoRehide = true;
        CanToggleAlwaysHiddenSection = true;
        EnableAlwaysHiddenSection = true;
        HideApplicationMenus = true;
        RehideInterval = 15;
        RehideStrategy = 0;
        UseIceBar = true;
        ShowIceIcon = true;
        ShowOnClick = true;
        ShowOnHover = false;
        ShowOnScroll = false;
        ShowSectionDividers = false;
        IceBarLocation = 0;
      };
    };
  };
}
