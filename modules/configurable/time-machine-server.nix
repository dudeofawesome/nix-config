{ lib, config, pkgs, ... }:
with lib; let
  cfg = config.services.samba.time-machine;
in
{
  options = {
    services.samba.time-machine = {
      enable = mkEnableOption "Apple Time Machine backup server";

      baseDir = mkOption {
        type = types.str;
        example = "/mnt/time-machine";
        description = ''
          The directory under which user's individual shares should be created.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "time-machine";
        description = ''
          The username that should own the files on disk.
        '';
      };

      users = mkOption {
        default = [ ];
        type = types.listOf types.str;
        example = [ "dudeofawesome" ];
        description = lib.mdDoc ''
          Usernames that should be allowed to back up to the Time Machine share.
        '';
      };
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isLinux) {
    environment.systemPackages = with pkgs; [
      # Add the samba CLI utils to enable debugging.
      samba
    ];

    services = {
      samba = {
        enable = true;
        openFirewall = true;
        shares = {
          "Time Machine" = {
            path = cfg.baseDir;
            comment = "Remote Time Machine target";
            "valid users" = concatStringsSep "," cfg.users;
            public = "no";
            writeable = "yes";
            "fruit:aapl" = "yes";
            "fruit:time machine" = "yes";
            "vfs objects" = "catia fruit streams_xattr";
          };
        };
      };

      avahi.enable = true;
    };

    # create service group
    users.groups.${cfg.group} = {
      members = cfg.users;
    };

    # create directory
    system.activationScripts.time-machine_mkdir = ''
      mkdir -p "${cfg.baseDir}"
      chown root:${cfg.group} "${cfg.baseDir}"
      chmod g+rw "${cfg.baseDir}"
    '';
  };
}
