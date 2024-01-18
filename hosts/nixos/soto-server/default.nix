{ config, pkgs, ... }: {
  imports = [ ];

  networking = {
    hostId = "2fad05b5"; # head -c 8 /etc/machine-id
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    shares = {
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

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
