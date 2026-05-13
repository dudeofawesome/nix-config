# WORKAROUND: https://github.com/openai/codex/issues/14767
{
  lib,
  config,
  pkgs,
  ...
}:
{
  config =
    let
      cfg = config.programs.codex;

      inherit (config.home) preferXdgDirectories;

      xdgConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
      configDir = if preferXdgDirectories then "${xdgConfigHome}/codex" else ".codex";
    in
    {
      home =
        let
          rulesDir = "${configDir}/rules";

          copyRuleFile =
            name: _content:
            let
              ruleFile = "/${rulesDir}/${name}.rules";
              source = lib.escapeShellArg config.home.file.${ruleFile}.source;
              targetPath = "${config.home.homeDirectory}/${rulesDir}/${name}.rules";
              target = lib.escapeShellArg targetPath;
            in
            ''
              run ${lib.getExe' pkgs.coreutils "install"} -D -m 0444 -p ${source} ${target}
            '';
        in
        lib.mkIf (cfg.enable) {
          file = lib.mkIf cfg.enable (
            lib.mapAttrs' (
              name: _content: lib.nameValuePair "/${rulesDir}/${name}.rules" { enable = false; }
            ) cfg.rules
          );

          activation.codexRules = lib.mkIf (cfg.enable && cfg.rules != { }) (
            lib.hm.dag.entryAfter [ "linkGeneration" ] (
              lib.concatStrings (lib.mapAttrsToList copyRuleFile cfg.rules)
            )
          );
        };
    };
}
