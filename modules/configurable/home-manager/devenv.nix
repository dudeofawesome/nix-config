{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    mkPackageOption
    mkIf
    mkAfter
    getExe
    types
    ;
  cfg = config.programs.devenv;

  shellArguments = [
    "--tui=${lib.boolToString cfg.arguments.tui}"
  ]
  ++ lib.mapAttrsToList (name: value: "--${name}=${toString value}") (
    lib.filterAttrs (_: value: value != null) (
      removeAttrs cfg.arguments [
        "tui"
        "trace-to"
      ]
    )
  )
  ++ lib.optionals (cfg.arguments.trace-to != null) (
    map (destination: "--trace-to=${destination}") (lib.splitString "," cfg.arguments.trace-to)
  );
  escapeFishArg = arg: "'${builtins.replaceStrings [ "\\" "'" ] [ "\\\\" "\\'" ] arg}'";
in
{
  options = {
    programs.devenv = {
      enable = mkEnableOption "Configure devenv";
      package = mkPackageOption pkgs-unstable "devenv" { };

      arguments = {
        tui = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = "Whether to enable interactive terminal interface";
        };
        max-jobs = mkOption {
          type = types.nullOr types.int;
          default = null;
          example = 1;
          description = "Maximum number of Nix builds to run concurrently";
        };
        cores = mkOption {
          type = types.nullOr types.int;
          default = null;
          example = 1;
          description = "Number of CPU cores available to each build";
        };
        trace-to = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "pretty:stderr,json:file:/tmp/trace.json";
          description = "Enable tracing to one or more destinations, comma-separated";
        };
        secretspec-provider = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Override the provider for the secretspec integration";
        };
        secretspec-profile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Override the profile for the secretspec integration";
        };
      };

      enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = [ cfg.package ];

    programs = {
      fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
        # Using `mkAfter` to make it more likely to appear after other
        # manipulations of the prompt.
        mkAfter ''
          ${getExe cfg.package} hook fish -- ${
            lib.concatMapStringsSep " " escapeFishArg shellArguments
          } | source
        ''
      );
    };
  };
}
