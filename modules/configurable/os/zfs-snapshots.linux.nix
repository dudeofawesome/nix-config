# Scheduled ZFS snapshots with one retention policy for the whole repo.
#
#   services.zfs-snapshots = {
#     enable = true;
#     datasets = [ "storage" ];   # snapshotted recursively
#   };
#
# The .linux.nix suffix matters: modules/configurable/os/default.nix imports
# every file here on every host, and nix-darwin has no `services.sanoid`.
#
# Implemented with sanoid. Replication to other disks or hosts is a separate
# concern (syncoid); see hosts/nixos/soto-server/offsite-backup.nix for one.
#
# Deliberately not under `services.zfs.*`: nixpkgs owns that namespace
# (`services.zfs.autoSnapshot`, `autoScrub`, `trim`, ...) and could add a
# `snapshots` option of its own.
{ config, lib, ... }:
let
  cfg = config.services.zfs-snapshots;
in
{
  options.services.zfs-snapshots = {
    enable = lib.mkEnableOption "scheduled ZFS snapshots (sanoid)";

    datasets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "storage" ];
      description = "Datasets to snapshot, each with all of its children.";
    };

    retention = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = {
        hourly = 48;
        daily = 30;
        monthly = 12;
        yearly = 2;
      };
      description = "How many snapshots of each interval to keep.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.sanoid = {
      enable = true;
      templates.default = cfg.retention // {
        autosnap = true;
        autoprune = true;
      };
      datasets = lib.genAttrs cfg.datasets (_: {
        useTemplate = [ "default" ];
        recursive = true;
      });
    };
  };
}
