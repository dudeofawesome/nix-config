{ config, pkgs, ... }:
{
  imports = [
    ./disko.nix
    ./offsite-backup.nix
    ./ssd-state-backup.nix
    ../../../modules/defaults/fs/bcachefs.nix
    ../../../modules/defaults/fs/snapper.nix
    ../../../modules/defaults/fs/zfs.nix
    ../../../modules/configurable/os/samba-users.nix
    ../../../modules/configurable/os/time-machine-server.linux.nix
  ];

  networking = {
    hostId = "2fad05b5"; # head -c 8 /etc/machine-id
    # DHCP on the first onboard NIC, in the initrd too (remote unlock over SSH port 222).
    interfaces.eno1.useDHCP = true;
  };

  # iDRAC out-of-band management credentials, used by scripts/ipmi.sh and
  # scripts/redfish.sh. 1Password item "Soto Server iDRAC".
  hardware.bmc.onePassword = {
    account = "orleans.1password.com";
    item = "scvtze3rk472qfoybwj43arhxi";
  };

  # Serial console over the iDRAC's Serial-Over-LAN (SOL).
  # This T430's iDRAC SOL is wired to COM2, which Linux enumerates as ttyS1.
  # The BIOS serial redirection (set out-of-band via racadm) must match:
  # "On with Console Redirection via COM2", 115200 baud.
  # `console=tty0` keeps local video working; the last `console=` listed
  # (ttyS1) receives the kernel log and gets a login getty, so the kernel,
  # initrd, and login prompt are all reachable over SOL. systemd starts
  # serial-getty@ttyS1 automatically because ttyS1 is a boot console.
  boot.kernelParams = [
    "console=tty0"
    "console=ttyS1,115200n8"
  ];

  # 1000M ESP, ~100M per generation.
  boot.loader.systemd-boot.configurationLimit = 10;

  # Hourly ZFS snapshots of everything in the storage pool; the offsite disks
  # replicate these.
  services.zfs-snapshots = {
    enable = true;
    datasets = [ "storage" ];
  };

  # Top-level directories on the pool belong to josh (the Time Machine
  # directory is managed by the time-machine module).
  systemd.tmpfiles.rules = [
    "d /storage/photos 0750 josh users -"
    "d /storage/media 0755 josh users -"
  ];

  # Samba password for josh, separate from the login password. Set at every
  # activation from this secret (modules/configurable/os/samba-users.nix).
  sops.secrets."hosts/nixos/soto-server/samba_password_josh" = {
    sopsFile = ./secrets.yaml;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    users = {
      enable = true;
      users.josh.plaintextPasswordFile =
        config.sops.secrets."hosts/nixos/soto-server/samba_password_josh".path;
    };
    time-machine = {
      enable = true;
      baseDir = "/storage/timemachine";
      users = [ "josh" ];
    };
    settings.public = {
      path = "/";
      browseable = "yes";
      "guest ok" = "yes";
      comment = "Public samba share";
    };
  };
}
