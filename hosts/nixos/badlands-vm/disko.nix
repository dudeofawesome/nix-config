{ lib, config, ... }:
let
  esp = import ../../../modules/defaults/disko/esp.nix;
  root = import ../../../modules/defaults/disko/root.nix {
    inherit lib;
    encrypted = true;
    passwordFile = config.sops.secrets."hosts/nixos/badlands-vm/fde_password".path;
  };
in
{
  sops.secrets."hosts/nixos/badlands-vm/fde_password" = {
    sopsFile = ./secrets.yaml;
  };

  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = esp // root.partition;
        };
        imageSize = "25G";
      };
    };

  };
}
