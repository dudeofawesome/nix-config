{
  lib,
  pkgs,
  pkgs-unstable,
  machine-class,
  config,
  ...
}:
{
  programs.opencode = {
    package = lib.mkDefault pkgs-unstable.opencode;

    enableMcpIntegration = lib.mkDefault true;

    web.enable = true;

    # rules = {
    #   nix = /* python */ ''
    #     prefix_rule(pattern = ["nix", "fmt"], decision = "allow")
    #     prefix_rule(pattern = ["nix", "build"], decision = "allow")
    #     prefix_rule(pattern = ["nix", "eval"], decision = "allow")
    #     prefix_rule(pattern = ["nix", "flake"], decision = "allow")
    #     prefix_rule(pattern = ["nix", "flake", "update"], decision = "prompt")
    #     prefix_rule(pattern = ["nix-prefetch-url"], decision = "allow")
    #   '';
    #   kubernetes = /* python */ ''
    #     def devenv_rule (pattern, **kwargs):
    #       prefix_rule(pattern, **kwargs)
    #       prefix_rule(
    #         pattern = ["devenv", "shell", "--quiet", "--"] + pattern,
    #         **kwargs,
    #       )

    #     # allow
    #     devenv_rule(pattern = ["kubectl", "get"], decision = "allow")
    #     devenv_rule(pattern = ["kubectl", "get", ["secret", "secrets"]], decision = "prompt")
    #     devenv_rule(pattern = ["kubectl", "describe"], decision = "allow")
    #     devenv_rule(pattern = ["kubectl", "describe", ["secret", "secrets"]], decision = "prompt")
    #     devenv_rule(pattern = ["kubectl", "logs"], decision = "allow")

    #     devenv_rule(pattern = ["flux", "get"], decision = "allow")
    #     devenv_rule(pattern = ["flux", "build"], decision = "allow")

    #     devenv_rule(pattern = ["helm", "template"], decision = "allow")

    #     devenv_rule(pattern = ["kustomize", "build"], decision = "allow")

    #     # forbid
    #     devenv_rule(
    #       pattern = ["kubectl", ["delete", "drain", "uninstall"]],
    #       decision = "forbidden",
    #       justification = "Destructive cluster operations are forbidden as they run against GitOps. Ask the user to run this manually if truly required."
    #     )
    #   '';
    # };

    settings = {

    };
  };
}
