{ config, ... }:
{
  imports = [
    ../../../modules/defaults/headful/gaming.darwin.nix
  ];

  homebrew = {
    casks = [
      "android-studio"
      "autodesk-fusion"
      "google-earth-pro"
    ];
  };

  services.scrutiny.collector = {
    enable = true;
    api-endpoint-secret = config.sops.templates."scrutiny-endpoint".path;
    settings = {
      host.id = config.networking.hostName;
      devices = [ { device = "/dev/disk0"; } ];
    };
  };

  environment.etc."fstab" = {
    text = ''
      # /etc/fstab: DO NOT EDIT -- this file has been generated automatically by nix-darwin.

      UUID=fbfb8f37-d08d-4db9-b0d0-4b3456a7675c /nix apfs rw,noatime,noauto,nobrowse,nosuid,owners # Added by the Determinate Nix Installer

      # disable auto-mounting Time Machine volumes for other systems
      UUID=3594CA5E-6412-4E77-8BAA-C7FF37E9752B none apfs rw,noauto
      UUID=F462EC05-1C97-408B-BC70-07C777A607AB none apfs rw,noauto
    '';

    knownSha256Hashes = [
      "bb6777d92974cbef6a288879e27cd9306887a4ddbd5f25dea097cc0a063103e1"
    ];
  };
}
