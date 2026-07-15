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

    rules = {
      nix = /* python */ ''
        prefix_rule(pattern = ["nix", "fmt"], decision = "allow")
        prefix_rule(pattern = ["nix", "build"], decision = "allow")
        prefix_rule(pattern = ["nix", "eval"], decision = "allow")
        prefix_rule(pattern = ["nix-prefetch-url"], decision = "allow")
      '';
      kubernetes = /* python */ ''
        def devenv_rule (pattern, **kwargs):
          prefix_rule(pattern, **kwargs)
          prefix_rule(
            pattern = ["devenv", "shell", "--quiet", "--"] + pattern,
            **kwargs,
          )

        # allow
        devenv_rule(pattern = ["kubectl", "get"], decision = "allow")
        devenv_rule(pattern = ["kubectl", "get", ["secret", "secrets"]], decision = "prompt")
        devenv_rule(pattern = ["kubectl", "describe"], decision = "allow")
        devenv_rule(pattern = ["kubectl", "describe", ["secret", "secrets"]], decision = "prompt")
        devenv_rule(pattern = ["kubectl", "logs"], decision = "allow")

        devenv_rule(pattern = ["flux", "get"], decision = "allow")
        devenv_rule(pattern = ["flux", "build"], decision = "allow")

        devenv_rule(pattern = ["helm", "template"], decision = "allow")

        devenv_rule(pattern = ["kustomize", "build"], decision = "allow")

        # forbid
        devenv_rule(
          pattern = ["kubectl", ["delete", "drain", "uninstall"]],
          decision = "forbidden",
          justification = "Destructive cluster operations are forbidden as they run against GitOps. Ask the user to run this manually if truly required."
        )
      '';
    };

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
