{
  lib,
  config,
  pkgs,
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
      builder.state = lib.mkDefault "enabled";

      garbageCollector.strategy = "automatic";
    };
  };

  nix.linux-builder.enable = lib.mkDefault false;

  # silence deprecation notice until 26.11
  nixpkgs.config.allowDeprecatedx86_64Darwin =
    lib.warnIf (lib.versionAtLeast (lib.versions.majorMinor pkgs.lib.version) "26.11")
      ''
        Remove nixpkgs.config.allowDeprecatedx86_64Darwin from
        modules/defaults/nix.darwin.nix now that nixpkgs is 26.11 or newer.
      ''
      true;

  # nix.extraOptions is not written when nix-darwin's Nix management is
  # disabled. Keep the SOPS-generated access token outside the Nix store and
  # include it from Determinate's custom configuration instead.
  environment.etc."nix/nix.custom.conf" = lib.mkIf hasGithubToken {
    text = ''
      !include ${config.sops.templates.${githubTokenPath}.path}
    '';
  };
}
