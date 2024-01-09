{ config, ... }: {
  # TODO: it might be possible to use sops-nix's templating to break out
  #   individual PSK secrets into their own keys
  sops.secrets."networking/wireless" = {
    format = "yaml";
  };

  networking.wireless = {
    enable = true;

    environmentFile = config.sops.secrets."networking/wireless".path;

    networks."orleans" = {
      psk = "%orleans_psk%";
    };
  };
}
