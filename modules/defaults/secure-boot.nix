{ lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  security.tpm2.enable = true;

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    initrd.availableKernelModules = [
      "tpm_crb"
      "tpm_tis"
    ];
  };
}
