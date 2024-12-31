{
  users,
  owner,
  machine-class,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.gnome;
in
{
  options = {
    programs.gnome = {
      autoLoginEnable = mkOption {
        type = types.bool;
        default =
          (machine-class == "local-vm")
          || (config.services.xserver.desktopManager.gnome.enable && config.services.qemuGuest.enable);
        example = true;
        description = ''
          Whether or not the specified user should be automatically logged in.
        '';
      };
      autoLoginUser = mkOption {
        type = types.str;
        default = owner;
        example = "dudeofawesome";
        description = ''
          The name of user that should be automatically logged in.
        '';
      };
    };
  };

  imports = [
    ../../../defaults/pipewire.nix
  ];

  config = {
    environment = {
      systemPackages = with pkgs; [
        gnome.dconf-editor
        gnomeExtensions.wayland-or-x11
      ];

      gnome.excludePackages = (
        with pkgs pkgs.gnome;
        [
          gnome-connections
          gnome-photos
          gnome-tour
          snapshot
          xterm
          cheese # webcam tool
          epiphany # web browser
          evince # document viewer
          geary # email reader
          gnome-calendar
          gnome-characters
          gnome-clocks
          gnome-contacts
          gnome-font-viewer
          gnome-maps
          gnome-music
          gnome-weather
          simple-scan
          yelp
        ]
      );
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = config.i18n.defaultLocale;
      LC_IDENTIFICATION = config.i18n.defaultLocale;
      LC_MEASUREMENT = config.i18n.defaultLocale;
      LC_MONETARY = config.i18n.defaultLocale;
      LC_NAME = config.i18n.defaultLocale;
      LC_NUMERIC = config.i18n.defaultLocale;
      LC_PAPER = config.i18n.defaultLocale;
      LC_TELEPHONE = config.i18n.defaultLocale;
      LC_TIME = config.i18n.defaultLocale;
    };

    services = {
      xserver = {
        enable = true;

        # Enable the GNOME Desktop Environment.
        displayManager.gdm = {
          enable = true;

          settings = {
            daemon = mkIf cfg.autoLoginEnable {
              AutomaticLoginEnable = cfg.autoLoginEnable;
              AutomaticLogin = cfg.autoLoginUser;
            };
          };
        };
        desktopManager.gnome.enable = true;

        # Enable touchpad support (enabled default in most desktopManager).
        # libinput.enable = true;
      };
    };
  };
}
