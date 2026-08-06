{
  inputs,
  config,
  lib,
  owner,
  pkgs,
  ...
}:
{
  imports = [
    inputs.jovian.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../../modules/defaults/fs/bcachefs.nix
    ../../../modules/defaults/fs/snapper.nix
    ../../../modules/defaults/headful/gnome.nix
    ../../../modules/defaults/jovian.nix
  ];

  # Jovian's Game Mode starts Steam Big Picture in Gamescope directly at boot.
  jovian = {
    hardware.has.amd.gpu = true;
    steamos = {
      enableHdmiCecIntegration = false;
    };

    steam = {
      enable = true;
      autoStart = true;
      user = owner;
    };
    decky-loader = {
      enable = true;
      # TODO: remove this backport https://github.com/SteamDeckHomebrew/decky-loader/pull/827
      package = pkgs.decky-loader.overridePythonAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./decky-loader-respect-path.patch ];
      });
      extraPackages = with pkgs; [
        procps
        systemd
      ];
      user = owner;

      plugins = [ pkgs.decky-launch-options ];
    };
  };

  networking.networkmanager.enable = true;
  security.tpm2.enable = true;

  services = {
    hardware.openrgb = {
      enable = true;
      # package = pkgs.openrgb.withPlugins (with pkgs; [ openrgb-plugin-effects ]);

      startupProfile = "orange";
    };

    ratbagd.enable = true;

    udev.extraRules = ''
      # Prevent mouse movement from waking the system through the Logitech Lightspeed receiver.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c539", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    '';
  };

  systemd.services.openrgb-profile = {
    description = "Apply an OpenRGB profile";
    requires = [ "openrgb.service" ];
    after = [
      "openrgb.service"
      "systemd-hibernate.service"
      "systemd-hybrid-sleep.service"
      "systemd-suspend.service"
      "systemd-suspend-then-hibernate.service"
    ];
    wantedBy = [
      "hibernate.target"
      "hybrid-sleep.target"
      "multi-user.target"
      "suspend.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig = {
      Type = "oneshot";
      User = owner;
      ExecStart = "${lib.getExe config.services.hardware.openrgb.package} --profile orange";
    };
  };

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    initrd = {
      systemd = {
        enable = lib.mkForce true;
        services =
          lib.genAttrs
            [
              "unlock-bcachefs-home"
              "unlock-bcachefs-nix"
              "unlock-bcachefs-tmp"
            ]
            (_: {
              # All subvolumes share the root filesystem's encryption key. Skip
              # their generated unlock attempts so they cannot race its mount.
              serviceConfig.ExecCondition = lib.mkForce "${pkgs.coreutils}/bin/false";
            });
      };
      availableKernelModules = [
        "tpm_crb"
        "tpm_tis"
      ];
      clevis = {
        enable = true;
        devices.${config.fileSystems."/".device}.secretFile = ./clevis.jwe;
      };
    };

    plymouth = {
      enable = true;

      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        # By default we would install all themes
        # (adi1090x-plymouth-themes.override {
        #   selected_themes = [ "rings" ];
        # })
        nixos-bgrt-plymouth
      ];

      # HiDPI
      # extraConfig = ''
      #   [Daemon]
      #   DeviceScale=1
      # '';
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };

  environment.systemPackages = with pkgs; [
    clevis
    sbctl
  ];

  networking = {
    hostId = "4164b7fd"; # head -c 8 /etc/machine-id
  };

  home-manager.users.dudeofawesome = {
    home.packages = with pkgs; [
      er-save-manager
    ];

    programs = {
      codex.enable = lib.mkForce false;
      opencode.enable = lib.mkForce false;
      vscode.enable = lib.mkForce false;
      zed-editor.enable = lib.mkForce false;
      fish.generateCompletions = false;
      kubectl.enable = lib.mkForce false;
      kubeconfig.enable = lib.mkForce false;
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
