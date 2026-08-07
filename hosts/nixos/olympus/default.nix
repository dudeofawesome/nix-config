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
    ../../../modules/defaults/plymouth.nix
    ../../../modules/defaults/secure-boot.nix
    ./clevis.nix
    ./openrgb.nix
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
      extraPackages = with pkgs; [
        procps
        systemd
      ];
      user = owner;

      plugins = [ pkgs.decky-launch-options ];
    };
  };

  # TODO: remove this once the ESP partition is actually resized
  disko.devices.disk.primary.content.partitions.ESP.size = lib.mkForce "500M";
  boot.loader.systemd-boot.configurationLimit =
    let
      avg_initrd_size = 100;
    in
    (lib.pipe config.disko.devices.disk.primary.content.partitions.ESP.size [
      (builtins.replaceStrings [ "M" ] [ "" ])
      lib.toInt
      (mb: mb / avg_initrd_size)
      lib.floor
    ]);

  networking.networkmanager.enable = true;

  services = {
    ratbagd.enable = true;

    udev.extraRules = ''
      # Prevent mouse movement from waking the system through the Logitech Lightspeed receiver.
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="046d", ATTR{idProduct}=="c539", TEST=="power/wakeup", ATTR{power/wakeup}="disabled"
    '';
  };

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
