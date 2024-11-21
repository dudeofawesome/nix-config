{ lib, config, ... }:
let
  esp = import ../../../modules/defaults/disko/esp.nix;
  root = import ../../../modules/defaults/disko/root.nix {
    inherit lib;
    encrypted = true;
    # passwordFile = config.sops.secrets."hosts/nixos/starling-vm/fde_password".path; # Louis told me to disable this because it was causing nixos-anywhere or something to look in the wrong location
    passwordFile = "/tmp/fde_password";
  };
in
{
  sops.secrets."hosts/nixos/starling-vm/fde_password" = {
    sopsFile = ./secrets.yaml;
  };

  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = esp // root.partition;
        };
        imageSize = "24G";
      };
    };

  };
}
