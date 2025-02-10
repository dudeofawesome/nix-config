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
          description = ''Users'';
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
            dudeofawesome = {
              client-certificate-data = config.sops.secrets.kube-cert.path;
              client-key-data = config.sops.secrets.kube-key.path;
            };
          };
        };

        clusters = mkOption {
          description = ''Clusters'';
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                server = mkOption {
                  type = with lib.types; path;
                  default = null;
                };
                certificate-authority-data = mkOption {
                  type = with lib.types; nullOr path;
                  default = null;
                };
              };
            }
          );
          default = { };
          example = {
            monongahela = {
              client-certificate-data = config.sops.secrets.kube-cert.path;
              client-key-data = config.sops.secrets.kube-key.path;
            };
          };
        };

        contexts = mkOption {
          description = ''Contexts to join clusters & users'';
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                cluster = mkOption {
                  type = with lib.types; str;
                  default = null;
                };
                user = mkOption {
                  type = with lib.types; str;
                  default = null;
                };
              };
            }
          );
          default = { };
          example = {
            doa-cluster = {
              cluster = "monongahela";
              user = "dudeofawesome";
            };
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
        kubeconfigCreate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p "$(dirname ~/"$(dirname "${cfg.path}")")"
          run touch ~/"${cfg.path}"
        '';

        kubeconfigSetUsers = lib.mkIf (cfg.users != { }) (
          lib.hm.dag.entryAfter [ "writeBoundary" "kubeconfigCreate" "sops-nix" ] ''
            run ${lib.getExe pkgs.yq-go} -i \
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

        kubeconfigSetClusters = lib.mkIf (cfg.clusters != { }) (
          lib.hm.dag.entryAfter [ "writeBoundary" "kubeconfigCreate" "sops-nix" ] ''
            run ${lib.getExe pkgs.yq-go} -i \
              '.clusters = ${
                lib.pipe cfg.clusters [
                  (lib.mapAttrsToList (
                    name: settings: {
                      inherit name;
                      cluster = lib.pipe settings [
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

        kubeconfigSetContexts = lib.mkIf (cfg.contexts != { }) (
          lib.hm.dag.entryAfter
            [ "writeBoundary" "kubeconfigCreate" "kubeconfigSetClusters" "kubeconfigSetUsers" ]
            ''
              # store old contexts
              old_ctx="$(
                ${lib.getExe pkgs.yq-go} \
                  --output-format json \
                  '.contexts' \
                  ~/"${cfg.path}"
              )"

              run ${lib.getExe pkgs.yq-go} -i \
                '.contexts = ${
                  lib.pipe cfg.contexts [
                    (lib.mapAttrsToList (
                      name: context: {
                        inherit name context;
                      }
                    ))
                    builtins.toJSON
                  ]
                }' \
                ~/"${cfg.path}"

              # restore active namespaces
              ${lib.pipe cfg.contexts [
                (lib.mapAttrsToList (
                  name: context: ''
                    namespace="$(
                      echo "$old_ctx" | ${lib.getExe pkgs.jq} \
                        --raw-output \
                        '.[] | select(.name == "${name}").context.namespace'
                    )"
                    run ${lib.getExe pkgs.yq-go} -i \
                      ".contexts[] |= select(.name == \"${name}\").context.namespace = \"$namespace\"" \
                      ~/"${cfg.path}"
                  ''
                ))
                (lib.concatStringsSep "\n")
              ]}
            ''
        );
      };
    };
}
