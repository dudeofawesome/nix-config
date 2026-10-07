{ ... }:
{
  imports = [ ];

  networking = {
    hostId = "2fad05b5"; # head -c 8 /etc/machine-id
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
        path = "/mnt/Shares/tm_share";
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
