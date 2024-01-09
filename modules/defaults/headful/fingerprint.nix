{ config, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      fprintd
    ];
  };

  services = {
    fprintd = {
      enable = true;
    };
  };

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
}
