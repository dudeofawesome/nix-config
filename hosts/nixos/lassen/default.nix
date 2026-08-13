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
    ../../../modules/defaults/headful/steamos.nix
    ../../../modules/defaults/secure-boot.nix
    ./clevis.nix
  ];

  # Jovian's Game Mode starts Steam Big Picture in Gamescope directly at boot.
  jovian = {
    devices.steamdeck = {
      enable = true;
      autoUpdate = true;
      # enableGyroDsuService = ;
    };
  };

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

  networking = {
    hostId = "426616de"; # head -c 8 /etc/machine-id
  };

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      # TODO: map over all disko disks
      devices = [ { device = config.disko.devices.disk.primary.device; } ];
    };
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
