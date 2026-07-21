{
  lib,
  config,
  owner,
  ...
}:
let
  githubTokenPath = "users/${owner}/nix_access_tokens.conf";
  hasGithubToken = builtins.hasAttr githubTokenPath config.sops.templates;
in
{
  determinateNix = {
    customSettings.auto-optimise-store = lib.mkDefault true;

    nixosVmBasedLinuxBuilder = {
      enable = lib.mkDefault false;
    };

    determinateNixd = {
      builder.state = "disabled";

      garbageCollector.strategy = "automatic";
    };
  };

  # nix.extraOptions is not written when nix-darwin's Nix management is
  # disabled. Keep the SOPS-generated access token outside the Nix store and
  # include it from Determinate's custom configuration instead.
  environment.etc."nix/nix.custom.conf" = lib.mkIf hasGithubToken {
    text = ''
      !include ${config.sops.templates.${githubTokenPath}.path}
    '';
  };
}
