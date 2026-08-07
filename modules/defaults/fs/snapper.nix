{ lib, config, ... }: {
  services.snapper = {
    snapshotInterval = "hourly";
    cleanupInterval = "1d";

    configs =
      let
        fs = config.fileSystems;
        snapshotting_fs = [
          "bcachefs"
          "btrfs"
        ];

        default_timeline = {
          TIMELINE_CREATE = lib.mkDefault true;
          TIMELINE_CLEANUP = lib.mkDefault true;

          TIMELINE_LIMIT_HOURLY = lib.mkDefault 4;
          TIMELINE_LIMIT_DAILY = lib.mkDefault 6;
          TIMELINE_LIMIT_WEEKLY = lib.mkDefault 3;
          TIMELINE_LIMIT_MONTHLY = lib.mkDefault 4;
          TIMELINE_LIMIT_YEARLY = lib.mkDefault 6;
        };
      in
      {
        root =
          let
            root = fs."/";
          in
          lib.mkIf (fs ? "/" && (builtins.elem root.fsType snapshotting_fs)) (
            default_timeline
            // {
              SUBVOLUME = "/";
              FSTYPE = root.fsType;
            }
          );

        home =
          let
            home = fs."/home";
          in
          lib.mkIf (fs ? "/home" && (builtins.elem home.fsType snapshotting_fs)) (
            default_timeline
            // {
              SUBVOLUME = "/home";
              FSTYPE = home.fsType;

              TIMELINE_LIMIT_HOURLY = 6;
              TIMELINE_LIMIT_DAILY = 12;
              TIMELINE_LIMIT_WEEKLY = 7;
            }
          );
      };
  };
}
