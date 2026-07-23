{ doa-lib, config, ... }:
{
  # TODO: it might be possible to use sops-nix's templating to break out
  #   individual PSK secrets into their own keys
  sops.secrets."networking/wireless" = {
    format = "yaml";
  };

  networking = {
    networkmanager = {
      enable = true;

      ensureProfiles = {
        environmentFiles = [ config.sops.secrets."networking/wireless".path ];
        profiles = {
          "orleans" = doa-lib.mkWirelessProfile {
            uuid = "6a2b7618-0898-4ef3-a6be-c9f4aee15e65";
            ssid = "orleans";
            psk = "$orleans_psk";
          };
        };
      };
    };
  };
}
