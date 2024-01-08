{ hostname, config, pkgs, ... }: {
  imports = [
  ];

  networking = {
    hostName = hostname;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
