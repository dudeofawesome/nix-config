{
  pkgs,
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
    mkIf
    mkDefault
    hasPrefix
    removePrefix
    ;
  cfg = config.home.file-json;
  homeDirectory = config.home.homeDirectory;
in
{
  meta = {
    maintainers = [ "dudeofawesome" ];
  };

  options = {
    home.file-json = lib.mkOption {
      description = "Attribute set of ";
      type = types.attrsOf (
        types.submodule (
          { name, config, ... }:
          {
            options = {
              enable = mkEnableOption "";

              target = mkOption {
                type = types.str;
                apply =
                  p:
                  let
                    absPath = if hasPrefix "/" p then p else "${homeDirectory}/${p}";
                  in
                  absPath;
                defaultText = literalExpression "name";
                description = ''
                  Path to target file relative to ${basePathDesc}.
                '';
              };

              extraConfig = mkOption {
                description = '''';
                type = types.attrs;
                default = { };
              };
            };

            config = {
              target = mkDefault name;
            };
          }
        )
      );
      default = { };
    };
  };

  config = {
    home.activation.setJsonValues = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.pipe cfg [
        (attrValues)
        # only run for enabled files
        (filter (v: v.enable))
        # convert extraConfig into `jq` commands
        (map (value: ''
          # jq will fail if the original file doesn't exist
          run ${pkgs.coreutils}/bin/touch '${value.target}'
          # set individual properties within a JSON file
          run ${lib.getExe pkgs.jq} \
            --raw-output \
            --null-input \
            --slurpfile original '${value.target}' \
            --argjson patch '${builtins.toJSON value.extraConfig}' \
            '($original[0] // {}) * $patch' \
          | run ${pkgs.moreutils}/bin/sponge '${value.target}'
        ''))
        (lib.concatStringsSep "\n")
      ]
    );
  };
}
