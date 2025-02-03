{
  pkgs,
  lib,
  config,
  ...
}:
{
  options =
    let
      inherit (lib) mkEnableOption mkOption;
    in
    {
      programs.kubeconfig = {
        enable = mkEnableOption "kubeconfig";

        path = mkOption {
          description = ''The path to put the kubeconfig at, relative to your home directory.'';
          type = lib.types.str;
          default = ".kube/config";
        };

        users = mkOption {
          description = ''Extra config options for 1Password's settings.json'';
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                token = mkOption {
                  type = with lib.types; nullOr path;
                  default = null;
                };
                client-certificate-data = mkOption {
                  type = with lib.types; nullOr path;
                  default = null;
                };
                client-key-data = mkOption {
                  type = with lib.types; nullOr path;
                  default = null;
                };
              };
            }
          );
          default = { };
          example = {
            client-certificate-data = config.sops.secrets.kube-cert.path;
            client-key-data = config.sops.secrets.kube-key.path;
          };
        };
      };
    };

  config =
    let
      cfg = config.programs.kubeconfig;
    in
    lib.mkIf cfg.enable {
      home.activation = {
        kubeconfigSetUsers = lib.mkIf (cfg.users != { }) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p "$(dirname ~/"$(dirname "${cfg.path}")")"

            $DRY_RUN_CMD ${lib.getExe pkgs.yq-go} -i \
              '.users = ${
                lib.pipe cfg.users [
                  (lib.mapAttrsToList (
                    name: settings: {
                      inherit name;
                      user = lib.pipe settings [
                        (lib.filterAttrsRecursive (k: v: v != null))
                        (lib.mapAttrsRecursive (
                          key: value:
                          if (builtins.isPath value || ((builtins.isString value) && (lib.hasPrefix "/" value))) then
                            "'$(cat ${value})'"
                          else
                            value
                        ))
                      ];
                    }
                  ))
                  builtins.toJSON
                ]
              }' \
              ~/"${cfg.path}"
          ''
        );
      };
    };
}
