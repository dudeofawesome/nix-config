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
    ../../../modules/defaults/headful/gnome.nix
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
      desktopSession = "gnome";
      user = owner;
    };
    decky-loader = {
      enable = true;
      user = owner;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ];

  # https://jovian-experiments.github.io/Jovian-NixOS/in-depth/decky-loader.html
  # Create Steam CEF debugging file if it doesn't exist for Decky Loader.
  systemd.services.steam-cef-debug = lib.mkIf config.jovian.decky-loader.enable {
    description = "Create Steam CEF debugging file";
    serviceConfig = {
      Type = "oneshot";
      User = config.jovian.steam.user;
      ExecStart = "/bin/sh -c 'mkdir -p ~/.steam/steam && [ ! -f ~/.steam/steam/.cef-enable-remote-debugging ] && touch ~/.steam/steam/.cef-enable-remote-debugging || true'";
    };
    wantedBy = [ "multi-user.target" ];
  };

  networking.networkmanager.enable = true;
  security.tpm2.enable = true;

  # Game Mode owns the graphical session; GDM from the PC machine class would
  # conflict with Jovian's autostart service.
  services = {
    displayManager.gdm.enable = lib.mkForce false;
    desktopManager.gnome.enable = lib.mkForce false;
  };

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    initrd = {
      systemd.enable = lib.mkForce true;
      availableKernelModules = [
        "tpm_crb"
        "tpm_tis"
      ];
      clevis = {
        enable = true;
        devices.${config.fileSystems."/".device}.secretFile = ./clevis.jwe;
      };
    };
  };

  environment.systemPackages = [
    pkgs.clevis
    pkgs.sbctl
  ];

  networking = {
    hostId = "4164b7fd"; # head -c 8 /etc/machine-id
  };

  home-manager.users.dudeofawesome = {
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
