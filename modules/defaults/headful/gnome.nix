{ config, pkgs, ... }: {
  imports = [
    ../pipewire.nix
  ];

  environment = {
    systemPackages = with pkgs; [
    ];

    gnome.excludePackages = (with pkgs; [
      gnome-connections
      gnome-photos
      gnome-tour
      snapshot
      xterm
    ]) ++ (with pkgs.gnome; [
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
    ]);
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
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Enable touchpad support (enabled default in most desktopManager).
      # libinput.enable = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dudeofawesome = {
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
