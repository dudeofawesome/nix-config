{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.thaw;
in
{
  options = {
    programs.thaw = {
      enable = lib.mkEnableOption "Thaw menu bar manager";

      package = lib.mkPackageOption pkgs "Thaw menu bar manager" {
        default = [ "thaw" ];
      };

      autoRehide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether hidden items should automatically rehide.";
      };

      canToggleAlwaysHiddenSection = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the always-hidden section can be toggled manually.";
      };

      enableAlwaysHiddenSection = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the always-hidden section is enabled.";
      };

      hideApplicationMenus = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether application menus should be hidden when necessary.";
      };

      rehideInterval = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Seconds to wait before rehiding shown items.";
      };

      rehideStrategy = lib.mkOption {
        # TODO: type this correctly. it's actually an enum
        type = lib.types.int;
        default = 0;
        description = "Rehide strategy integer used by Thaw.";
      };

      useIceBar = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show hidden items in the Thaw bar.";
      };

      showIceIcon = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to show the Thaw menu bar icon.";
      };

      showOnClick = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether hidden items should show when clicking the menu bar.";
      };

      showOnHover = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether hidden items should show on hover.";
      };

      showOnScroll = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether hidden items should show on scroll.";
      };

      showSectionDividers = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether section dividers should be shown.";
      };

      iceBarLocation = lib.mkOption {
        # TODO: type this correctly. it's actually an enum
        type = lib.types.int;
        default = 0;
        description = "Thaw bar location integer used by the app.";
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.packages = [ cfg.package ];

    targets.darwin.defaults."com.stonerl.Thaw" = {
      AutoRehide = cfg.autoRehide;
      CanToggleAlwaysHiddenSection = cfg.canToggleAlwaysHiddenSection;
      EnableAlwaysHiddenSection = cfg.enableAlwaysHiddenSection;
      HideApplicationMenus = cfg.hideApplicationMenus;
      RehideInterval = cfg.rehideInterval;
      RehideStrategy = cfg.rehideStrategy;
      UseIceBar = cfg.useIceBar;
      ShowIceIcon = cfg.showIceIcon;
      ShowOnClick = cfg.showOnClick;
      ShowOnHover = cfg.showOnHover;
      ShowOnScroll = cfg.showOnScroll;
      ShowSectionDividers = cfg.showSectionDividers;
      # SectionDividerStyle = ;
      # ShowAllSectionsOnUserDrag = ;
      # ShowMenuBarTooltips = ;
      # UseIceBarOnlyOnNotchedDisplay = ;
      IceBarLocation = cfg.iceBarLocation;

      SUEnableAutomaticChecks = cfg.package != null;
    };
  };
}
