{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    literalExpression
    ;
  yamlFormat = pkgs.formats.yaml { };

  cfg = config.programs.glab;
in
{
  meta.maintainers = with lib.maintainers; [
    dudeofawesome
  ];

  options =
    let
      settingsType = types.submodule {
        freeformType = yamlFormat.type;
        # These options are only here for the `mkRenamedOptionModule` support
        options = {
          editor = mkOption {
            type = types.str;
            default = "";
            description = ''
              The editor that glab should run when creating issues, pull requests, etc.
              If blank, will refer to environment.
            '';
          };
          browser = mkOption {
            type = types.str;
            default = "";
            description = ''
              The web browser to use for opening links.
            '';
          };
          git_protocol = mkOption {
            type = types.str;
            default = "ssh";
            example = "https";
            description = ''
              The protocol to use when performing Git operations.
            '';
          };
          check_update = mkOption {
            type = types.bool;
            default = true;
            example = false;
            description = ''
              Allow glab to automatically check for updates and notify you when
              there are new updates.
            '';
          };
        };
      };
    in
    {
      programs.glab = {
        enable = mkEnableOption "Whether to enable Gitlab CLI tool.";
        package = lib.mkPackageOption pkgs "GitLab CLI tool" {
          default = [ "glab" ];
        };

        # gitCredentialHelper.enable
        # gitCredentialHelper.hosts
        # hosts
        # aliases.yml

        settings = mkOption {
          type = settingsType;
          default = { };
          description = "Configuration written to {file}`$XDG_CONFIG_HOME/glab-cli/config.yml`.";
          example = literalExpression ''
            {
              git_protocol = "ssh";

              no_prompt = false;
            };
          '';
        };

        hostTokenSecrets = mkOption {
          type = types.attrsOf types.str;
          default = { };
          description = ''
            Map of GitLab host to the name of the sops secret holding its API
            token. When set, {file}`config.yml` is rendered by sops-nix with
            mode 0600 instead of linked from the Nix store, since glab refuses
            to read a config file it can't write.
          '';
          example = literalExpression ''
            {
              "gitlab.example.com" = "users/alice/glab/example/api_token";
            }
          '';
        };
      };
    };

  config = mkIf (cfg.enable) (
    let
      useSops = cfg.hostTokenSecrets != { };
      settings = lib.recursiveUpdate cfg.settings {
        hosts = lib.mapAttrs (_: secret: {
          token = config.sops.placeholder.${secret};
        }) cfg.hostTokenSecrets;
      };
    in
    {
      home.packages = [ cfg.package ];

      xdg.configFile = mkIf (!useSops) {
        "glab-cli/config.yml".source = yamlFormat.generate "glab-config.yml" cfg.settings;
      };

      sops = mkIf useSops {
        secrets = lib.genAttrs (lib.attrValues cfg.hostTokenSecrets) (_: { });
        templates."glab-cli-config.yml" = {
          file = yamlFormat.generate "glab-config.yml" settings;
          path = "${config.xdg.configHome}/glab-cli/config.yml";
          mode = "0600";
        };
      };
    }
  );
}
