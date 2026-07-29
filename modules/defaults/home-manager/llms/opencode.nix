{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
{
  home = {
    packages = with pkgs; [
      bash-language-server
      nixd
      (pkgs.symlinkJoin {
        name = "opencode-desktop-without-bin";
        paths = [ opencode-desktop ];
        postBuild = ''
          rm -rf "$out/bin"
        '';
      })
      yaml-language-server
    ];

    sessionVariables = {
      OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
    };
  };

  sops = {
    templates.opencodeWebEnv = {
      content = ''
        export OPENCODE_SERVER_USERNAME="${config.home.username}";
        export OPENCODE_SERVER_PASSWORD="${
          config.sops.placeholder."users/${config.home.username}/opencode/server/password"
        }";
      '';
    };
  };

  programs.opencode = {
    package = lib.mkDefault pkgs-unstable.opencode;

    enableMcpIntegration = lib.mkDefault true;

    web = {
      enable = true;

      environmentFile = lib.traceVal config.sops.templates.opencodeWebEnv.path;
    };

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
      lsp = true;

      permission = {
        bash = {
          "*" = "ask";

          "devenv *" = "ask";
          "devenv init" = "allow";
          "devenv search" = "allow";
          "devenv build" = "allow";
          "devenv mcp" = "allow";
          "devenv help" = "allow";
          "devenv shell *" = "ask";

          "nix *" = "ask";
          "nix fmt *" = "allow";
          "nix build *" = "allow";
          "nix eval *" = "allow";
          "nix flake *" = "allow";
          "nix flake update *" = "ask";
          "nix-prefetch-url" = "allow";

          "kubectl *" = "ask";
          "kubectl get *" = "allow";
          "kubectl get secret *" = "deny";
          "kubectl get secrets *" = "deny";
          "kubectl describe *" = "allow";
          "kubectl describe secret *" = "deny";
          "kubectl describe secrets *" = "deny";
          "kubectl logs *" = "allow";

          "flux get *" = "allow";
          "flux build *" = "allow";

          "helm *" = "ask";
          "helm template *" = "allow";

          "kustomize *" = "ask";
          "kustomize build *" = "allow";

          "git *" = "allow";
          "git commit *" = "ask";
        };
      };
    };
  };
}
