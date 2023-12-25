{ hostname, config, pkgs, ... }: {
  imports = [
    ../configuration.nix
  ];

  networking = {
    hostName = hostname;
  };

  environment = {
    systemPackages = with pkgs; [
    ];
  };
}
