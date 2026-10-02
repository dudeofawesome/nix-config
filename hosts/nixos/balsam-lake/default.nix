{
  inputs,
  config,
  lib,
  ...
}:
{
  # Before installation, enroll this host's age recipient in .sops.yaml and
  # updatekeys secrets/secrets.yaml, users/dudeofawesome/secrets.yaml, and
  # modules/presets/os/doa-cluster/secrets.yaml. Preserve its private key on disk.
  # Follow Olympus's native-bcachefs install flow using this host's disk/config;
  # create fresh Secure Boot keys and enroll this host's TPM after first boot.
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    ../../../modules/defaults/fs/bcachefs.nix
    ../../../modules/defaults/secure-boot.nix
    ../../../modules/defaults/wireless.nix
    ../../../modules/presets/os/doa-cluster
    ./clevis.nix
  ];

  networking = {
    hostId = "fc5629ed"; # head -c 8 /etc/machine-id
    firewall.enable = false;
  };

  services.k3s = {
    role = "agent";
    serverAddr = "https://10.0.1.192:6443";
  };

  # The T540 has only ~3.2 GiB usable RAM. Bound logs and concurrent builds.
  fileSystems."/var/log/pods".options = lib.mkForce [
    "mode=0755"
    "nosuid"
    "nodev"
    "noexec"
    "noswap"
    "size=64M"
  ];
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      devices = [ { device = config.disko.devices.disk.primary.device; } ];
    };
  };

  # Initial installation release; retain this across future upgrades.
  system.stateVersion = "26.05";
}
