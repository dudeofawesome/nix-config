{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.extraModulePackages = lib.mkIf config.boot.initrd.clevis.enable [
    config.boot.kernelPackages.tsme-test
  ];

  environment.systemPackages = with pkgs; [
    clevis
  ];

  boot = {
    initrd = {
      clevis = {
        enable = true;
      };
    };
  };
}
