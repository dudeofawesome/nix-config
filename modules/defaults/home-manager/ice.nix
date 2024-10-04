{ pkgs, lib, config, ... }:
{
  targets.darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    defaults."com.jordanbaird.Ice" = {
      AutoRehide = true;
      CanToggleAlwaysHiddenSection = true;
      EnableAlwaysHiddenSection = true;
      HideApplicationMenus = true;
      RehideInterval = 15;
      RehideStrategy = 0;
      ShowIceIcon = true;
      ShowOnClick = true;
      ShowOnHover = false;
      ShowOnHoverDelay = "0.2";
      ShowOnScroll = false;
      ShowSectionDividers = false;
      UseIceBar = true;
    };
  };
}
