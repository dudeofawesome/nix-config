{ config, pkgs, ... }:
{
  imports = [
    ./disko.nix
    ./offsite-backup.nix
    ./ssd-state-backup.nix
    ../../../modules/defaults/boot/bcachefs-unlock-once.nix
    ../../../modules/defaults/fs/bcachefs.nix
    ../../../modules/defaults/fs/snapper.nix
    ../../../modules/defaults/fs/zfs.nix
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

  # Hourly ZFS snapshots of everything in the storage pool. The offsite disks
  # replicate these; keep enough history that a bad deletion is recoverable.
  services.sanoid = {
    enable = true;
    templates.production = {
      hourly = 48;
      daily = 30;
      monthly = 12;
      yearly = 2;
      autosnap = true;
      autoprune = true;
    };
    datasets.storage = {
      useTemplate = [ "production" ];
      recursive = true;
    };
  };

  # Top-level directories on the pool belong to josh.
  systemd.tmpfiles.rules = [
    "d /storage/photos 0750 josh users -"
    "d /storage/media 0755 josh users -"
    "d /storage/timemachine 0750 josh users -"
  ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      public = {
        path = "/";
        browseable = "yes";
        "guest ok" = "yes";
        comment = "Public samba share";
      };
      "Time Machine" = {
        path = "/storage/timemachine";
        comment = "Remote Time Machine target";
        "valid users" = "josh";
        public = "no";
        writeable = "yes";
        "force user" = "josh";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };
}
