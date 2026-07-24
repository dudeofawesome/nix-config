{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
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

      };
    };

  config = mkIf (cfg.enable) {
    home.packages = [ cfg.package ];

    xdg.configFile = {
      "glab-cli/config.yml".source = yamlFormat.generate "glab-config.yml" (cfg.settings);
    };
  };
}
