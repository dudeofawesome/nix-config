{
  inputs,
  config,
  owner,
  ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../../modules/defaults/fs/bcachefs.nix
    ../../../modules/defaults/secure-boot.nix
    # ../../../modules/defaults/nvidia.nix
    ../../../modules/defaults/tailscale.nix
    ../../../modules/defaults/tang.nix
    ../../../modules/presets/os/doa-cluster
    ./clevis.nix
  ];

  # Retain the repository deploy credential during the service migration.
  # Enroll kings-canyon as a recipient before installing (see README).
  sops.secrets."hosts/nixos/kings-canyon/ssh-keys/dudeofawesome_nix-config/private" = {
    sopsFile = ./secrets.yaml;
    path = "/home/${owner}/.ssh/github_dudeofawesome_nix-config_ed25519";
    inherit owner;
    mode = "0400";
  };

  networking = {
    hostId = "f5764075"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  services = {
    tang.ipAddressAllow = [ "10.0.0.0/20" ];

    games-on-whales.wolf = {
      enable = true;
      openFirewall = true;
    };

    scrutiny.collector = {
      enable = true;
      api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
      settings = {
        host.id = config.networking.hostName;
        devices = [ { device = config.disko.devices.disk.primary.device; } ];
      };
    };
  };

  # Keep the GPU configuration ready while the NVIDIA card is not installed.
  # Wait for driver loading and device creation before checking availability.
  systemd.services.nvidia-container-toolkit-cdi-generator = {
    after = [
      "systemd-modules-load.service"
      "systemd-udev-settle.service"
    ];
    wants = [ "systemd-udev-settle.service" ];
    # The control device can exist even when no GPU was found.
    unitConfig.ConditionPathExistsGlob = "/proc/driver/nvidia/gpus/*";
  };

  # First boot is for enrollment and restoring state, before taking over services.
  systemd.services.k3s.unitConfig.ConditionPathExists = "/var/lib/kings-canyon/migration-ready";
  systemd.services.podman-wolf.unitConfig.ConditionPathExists =
    "/var/lib/kings-canyon/migration-ready";
  systemd.sockets.tangd.unitConfig.ConditionPathExists = "/var/lib/kings-canyon/migration-ready";

  # Initial installation release; retain this across future upgrades.
  system.stateVersion = "26.05";
}
