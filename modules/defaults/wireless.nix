{ lib, config, ... }:
let
  mkWirelessProfile = { uuid, ssid, psk }: {
    connection = {
      inherit uuid;
      id = ssid;
      type = "wifi";
    };
    wifi = {
      inherit ssid;
      mode = "infrastructure";
    };
    wifi-security = {
      inherit psk;
      key-mgmt = "wpa-psk";
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      method = "auto";
    };
  };
in
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
          "orleans" = mkWirelessProfile {
            uuid = "6a2b7618-0898-4ef3-a6be-c9f4aee15e65";
            ssid = "orleans";
            psk = "$orleans_psk";
          };
          "Frontier0818" = mkWirelessProfile {
            uuid = "a5d0b970-3641-4748-a68b-0627a691ac91";
            ssid = "Frontier0818";
            psk = "$Frontier0818_psk";
          };
        };
      };
    };
  };
}
