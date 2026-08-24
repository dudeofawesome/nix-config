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
    (lib.optional (
      machine-class == "pc" && lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.chatgpt-desktop
    ) pkgs.chatgpt-desktop)
  ];

  programs.codex = {
    package = lib.mkDefault pkgs-unstable.codex;

    enableMcpIntegration = lib.mkDefault true;

    rules = {
      nix = /* python */ ''
        prefix_rule(pattern = ["nix", "fmt"], decision = "allow")
        prefix_rule(pattern = ["nix", "build"], decision = "allow")
        prefix_rule(pattern = ["nix", "eval"], decision = "allow")
        prefix_rule(pattern = ["nix", "flake"], decision = "allow")
        prefix_rule(pattern = ["nix", "flake", "update"], decision = "prompt")
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
      tui = {
        # TODO: make this also flash the screen if muted
        notifications = [
          "agent-turn-complete"
          "approval-requested"
        ];
        notification_condition = "always";
        notification_method = "auto";
      };

      features = {
        default_mode_request_user_input = true;
      };
    };
  };
}
