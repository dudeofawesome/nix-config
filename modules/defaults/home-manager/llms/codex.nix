{
  lib,
  pkgs,
  pkgs-unstable,
  machine-class,
  config,
  ...
}:
{
  home.packages = lib.flatten [
    (lib.optional (machine-class == "pc") pkgs.codex-desktop)
  ];

  programs.codex = {
    package = lib.mkDefault pkgs-unstable.codex;

    enableMcpIntegration = lib.mkDefault true;

    rules.nix = ''
      prefix_rule(pattern = ["nix", "fmt"], decision = "allow")
      prefix_rule(pattern = ["nix", "build"], decision = "allow")
      prefix_rule(pattern = ["nix", "eval"], decision = "allow")
      prefix_rule(pattern = ["nix-prefetch-url"], decision = "allow")
    '';

    settings = {
      # TODO: make this also flash the screen if muted
      # TODO: make this alert only when codex is done with a turn or asking for permission
      notify = [
        "bash"
        "-lc"
        "afplay --volume 3 /System/Library/Sounds/Bottle.aiff"
      ];
    };
  };
}
# WORKAROUND: https://github.com/openai/codex/issues/14767
// {
  home =
    let
      cfg = config.programs.codex;

      packageVersion = if cfg.package != null then lib.getVersion cfg.package else "0.94.0";
      useXdgDirectories = config.home.preferXdgDirectories && lib.versionAtLeast packageVersion "0.2.0";
      xdgConfigHome = lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome;
      homeFileXdgConfigHome = lib.removePrefix config.home.homeDirectory config.xdg.configHome;
      configDir = if useXdgDirectories then "${xdgConfigHome}/codex" else ".codex";
      homeFileConfigDir = if useXdgDirectories then "${homeFileXdgConfigHome}/codex" else ".codex";
      rulesDir = "${configDir}/rules";
      homeFileRulesDir = "${homeFileConfigDir}/rules";

      copyRuleFile =
        name: _content:
        let
          target = lib.escapeShellArg "${config.home.homeDirectory}/${rulesDir}/${name}.rules";
        in
        ''
          if [ -L ${target} ]; then
            source="$(${lib.getExe' pkgs.coreutils "readlink"} ${target})"
            run ${lib.getExe' pkgs.coreutils "rm"} ${target}
            run ${lib.getExe' pkgs.coreutils "install"} -m 0644 "$source" ${target}
          fi
        '';
    in
    {
      file = lib.mkIf cfg.enable (
        lib.mapAttrs' (
          name: _content: lib.nameValuePair "${homeFileRulesDir}/${name}.rules" { force = true; }
        ) cfg.rules
      );

      activation.codexRules = lib.mkIf (cfg.enable && cfg.rules != { }) (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          lib.concatStrings (lib.mapAttrsToList copyRuleFile cfg.rules)
        )
      );
    };
}
