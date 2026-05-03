{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:
with builtins;
let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkPackageOption
    hasPrefix
    any
    literalExpression
    versionAtLeast
    ;

  cfg = config.home.file-mutable;
  toolCfg = config.home.file-mutable-options;
  homeDirectory = config.home.homeDirectory;
  tomlFormat = pkgs.formats.toml { };
  hasEnabledTomlMutableFile = any (value: value.enable && value.format == "toml") (attrValues cfg);

  patchFileFor =
    name: value:
    if value.format == "json" then
      pkgs.writeText "${name}.json" (
        if isAttrs value.extraConfig then toJSON value.extraConfig else value.extraConfig
      )
    else if isAttrs value.extraConfig then
      tomlFormat.generate "${name}.toml" value.extraConfig
    else
      pkgs.writeText "${name}.toml" value.extraConfig;
in
{
  meta = {
    maintainers = [ "dudeofawesome" ];
  };

  options = {
    home.file-mutable-options = {
      jqPackage = mkPackageOption pkgs "jq" {
        default = [ "jq" ];
      };

      yqPackage = mkPackageOption pkgs-unstable "yq-go" {
        default = [ "yq-go" ];
      };
    };

    home.file-mutable = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { name, ... }:
          {
            options = {
              enable = mkEnableOption "";

              format = mkOption {
                type = types.enum [
                  "json"
                  "toml"
                ];
                description = "Structured file format used for merging.";
              };

              target = mkOption {
                type = types.str;
                apply = p: if hasPrefix "/" p then p else "${homeDirectory}/${p}";
                default = name;
                defaultText = literalExpression "name";
                description = "Path to the mutable target file.";
              };

              extraConfig = mkOption {
                type = with types; either attrs str;
                default = { };
                description = "Patch data as an attribute set or raw format-specific text.";
              };
            };
          }
        )
      );
      description = "Attribute set of mutable structured files managed outside the Nix store.";
    };
  };

  config = {
    assertions = [
      {
        assertion = !hasEnabledTomlMutableFile || versionAtLeast toolCfg.yqPackage.version "4.53.2";
        message = ''
          `home.file-mutable` TOML support requires `home.file-mutable-options.yqPackage` version 4.53.2 or newer.
          Current version: ${toolCfg.yqPackage.version}
        '';
      }
    ];

    home.activation.setMutableFileValues = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.pipe cfg [
        (lib.mapAttrsToList (
          name: value: {
            inherit name value;
            patchFile = patchFileFor name value;
          }
        ))
        (filter ({ value, ... }: value.enable))
        (map (
          { value, patchFile, ... }:
          ''
            run ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(${lib.getExe' pkgs.coreutils "dirname"} '${value.target}')"
            run ${lib.getExe' pkgs.coreutils "touch"} '${value.target}'
            ${
              if value.format == "json" then
                ''
                  run ${lib.getExe toolCfg.jqPackage} \
                    --raw-output \
                    --null-input \
                    --slurpfile original '${value.target}' \
                    --slurpfile patch '${patchFile}' \
                    '($original[0] // {}) * ($patch[0] // {})' \
                  | run ${pkgs.moreutils}/bin/sponge '${value.target}'
                ''
              else if value.format == "toml" then
                ''
                  if [ ! -s '${value.target}' ]; then
                    run ${pkgs.coreutils}/bin/cp '${patchFile}' '${value.target}'
                  else
                    root_expr='. as $item ireduce ({}; . * $item) | with_entries(select(.value | kind != "map"))'
                    table_expr='. as $item ireduce ({}; . * $item) | with_entries(select(.value | kind == "map"))'

                    root_output="$(${lib.getExe toolCfg.yqPackage} eval-all \
                      --input-format toml \
                      --output-format toml \
                      "$root_expr" \
                      '${value.target}' \
                      '${patchFile}')"

                    table_output="$(${lib.getExe toolCfg.yqPackage} eval-all \
                      --input-format toml \
                      --output-format toml \
                      "$table_expr" \
                      '${value.target}' \
                      '${patchFile}')"

                    printf '%s\n\n%s\n' "$root_output" "$table_output" \
                    | run ${pkgs.moreutils}/bin/sponge '${value.target}'
                  fi
                ''
              else
                throw "Unsupported format: ${value.format}"
            }
          ''
        ))
        (lib.concatStringsSep "\n")
      ]
    );
  };
}
