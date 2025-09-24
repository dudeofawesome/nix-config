# from https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/search/qdrant.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qdrant;

  settingsFormat = pkgs.formats.yaml { };
  configFile = settingsFormat.generate "config.yaml" cfg.settings;
in
{
  options = {
    services.qdrant = {
      enable = lib.mkEnableOption "Vector Search Engine for the next generation of AI applications";
      package = lib.mkPackageOption pkgs "qdrant" { };

      maxOpenFiles = lib.mkOption {
        type = lib.types.int;
        default = 32768;
        description = ''
          Maximum number of open file descriptors for the qdrant process.
          This helps prevent "too many open files" errors when working with
          large datasets or multiple collections.

          Recommended values:
          - Light usage: 16384
          - Default: 32768 (suitable for most workloads)
          - Heavy production: 65536
        '';
      };

      settings = lib.mkOption {
        description = ''
          Configuration for Qdrant
          Refer to <https://github.com/qdrant/qdrant/blob/master/config/config.yaml> for details on supported values.
        '';

        type = settingsFormat.type;

        example = {
          storage = {
            storage_path = "/var/lib/qdrant/storage";
            snapshots_path = "/var/lib/qdrant/snapshots";
          };
          hsnw_index = {
            on_disk = true;
          };
          service = {
            host = "127.0.0.1";
            http_port = 6333;
            grpc_port = 6334;
          };
          telemetry_disabled = true;
        };

        defaultText = lib.literalExpression ''
          {
            storage = {
              storage_path = "${config.xdg.dataHome}/qdrant/storage";
              snapshots_path = "${config.xdg.dataHome}/qdrant/snapshots";
            };
            hsnw_index = {
              on_disk = true;
            };
            service = {
              host = "127.0.0.1";
              http_port = 6333;
              grpc_port = 6334;
            };
            telemetry_disabled = true;
          }
        '';
      };
    };
  };

  config =
    let
      inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;

    in
    lib.mkIf cfg.enable {
      services.qdrant.settings = {
        service.static_content_dir = lib.mkDefault pkgs.qdrant-web-ui;
        storage.storage_path = lib.mkDefault "${config.xdg.dataHome}/qdrant/storage";
        storage.snapshots_path = lib.mkDefault "${config.xdg.dataHome}/qdrant/snapshots";
        # The following default values are the same as in the default config,
        # they are just written here for convenience.
        storage.on_disk_payload = lib.mkDefault true;
        storage.wal.wal_capacity_mb = lib.mkDefault 32;
        storage.wal.wal_segments_ahead = lib.mkDefault 0;
        storage.performance.max_search_threads = lib.mkDefault 0;
        storage.performance.max_optimization_threads = lib.mkDefault 1;
        storage.optimizers.deleted_threshold = lib.mkDefault 0.2;
        storage.optimizers.vacuum_min_vector_number = lib.mkDefault 1000;
        storage.optimizers.default_segment_number = lib.mkDefault 0;
        storage.optimizers.max_segment_size_kb = lib.mkDefault null;
        storage.optimizers.memmap_threshold_kb = lib.mkDefault null;
        storage.optimizers.indexing_threshold_kb = lib.mkDefault 20000;
        storage.optimizers.flush_interval_sec = lib.mkDefault 5;
        storage.optimizers.max_optimization_threads = lib.mkDefault 1;
        storage.hnsw_index.m = lib.mkDefault 16;
        storage.hnsw_index.ef_construct = lib.mkDefault 100;
        storage.hnsw_index.full_scan_threshold_kb = lib.mkDefault 10000;
        storage.hnsw_index.max_indexing_threads = lib.mkDefault 0;
        storage.hnsw_index.on_disk = lib.mkDefault false;
        storage.hnsw_index.payload_m = lib.mkDefault null;
        service.max_request_size_mb = lib.mkDefault 32;
        service.max_workers = lib.mkDefault 0;
        service.http_port = lib.mkDefault 6333;
        service.grpc_port = lib.mkDefault 6334;
        service.enable_cors = lib.mkDefault true;
        cluster.enabled = lib.mkDefault false;
        # the following have been altered for security
        service.host = lib.mkDefault "127.0.0.1";
        telemetry_disabled = lib.mkDefault true;
      };

      systemd.user.services.qdrant = lib.mkIf isLinux {
        Install.WantedBy = [ "default.target" ];
        Unit = {
          Description = "Vector Search Engine for the next generation of AI applications";
        };

        Service.ExecStart = "${lib.getExe' cfg.package "qdrant"} --config-path ${configFile}";
      };

      launchd.agents.qdrant = lib.mkIf isDarwin {
        enable = true;
        config = {
          ProcessType = "Background";
          ProgramArguments = [
            (lib.getExe' cfg.package "qdrant")
            "--config-path"
            "${configFile}"
          ];
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };

          # Resource limits to prevent "too many open files" errors
          SoftResourceLimits = {
            NumberOfFiles = cfg.maxOpenFiles;
          };
          HardResourceLimits = {
            NumberOfFiles = cfg.maxOpenFiles;
          };

          # StandardOutPath = "/tmp/qdrant.stdout.log";
          # StandardErrorPath = "/tmp/qdrant.stderr.log";
        };
      };
    };
}
