{
  inputs,
  pkgs,
  lib,
  doa-lib,
  config,
  os,
  owner,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isLinux isDarwin;

  mkDarwinDefault = lib.mkOverride 99;

  githubTokenPath = "users/${owner}/nix_access_tokens.conf";
  hasGithubToken = builtins.hasAttr githubTokenPath config.sops.templates;
  githubTokenInclude = ''
    !include ${config.sops.templates.${githubTokenPath}.path}
  '';
in
{
  imports = [ (doa-lib.try-import ./nix.${os}.nix) ];

  nix = {
    enable = !isDarwin;

    package = pkgs.nix;

    gc = {
      # Determinate Nix manages garbage collection on macOS.
      automatic = !isDarwin;
      options = lib.mkDefault "--delete-older-than 30d";
    }
    // (
      if (isLinux) then
        { dates = lib.mkDefault "weekly"; }
      else if (isDarwin) then
        {
          interval = {
            Weekday = lib.mkDefault 7;
            # macOS supposedely won't schedule jobs without a minute set (FB7740271, can't find this ticket though)
            Hour = lib.mkDefault 0;
            Minute = lib.mkDefault 0;
          };
        }
      else
        abort "unsupported OS ${pkgs.stdenv.targetPlatform.config}"
    );

    optimise = {
      # Determinate Nix uses auto-optimise-store on macOS instead.
      automatic = lib.mkDefault (!isDarwin);
    }
    // (
      if (isLinux) then
        { dates = lib.mkDefault [ "03:45" ]; }
      else if (isDarwin) then
        {
          interval = lib.mkDefault {
            Hour = 4;
            Minute = 15;
          };
        }
      else
        abort "unsupported OS ${pkgs.stdenv.targetPlatform.config}"
    );

    # disable the nix-channel command, which leads to non-reproducible envs
    channel.enable = false;

    settings =
      let
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          # nix-node by fontis
          "https://fontis.cachix.org/"
          # claude-code-nix
          "https://claude-code.cachix.org"
          # codex-cli-nix
          "https://codex-cli.cachix.org"
          # nixos-raspberrypi
          "https://nixos-raspberrypi.cachix.org"
        ];
      in
      {
        experimental-features = "nix-command flakes";
        use-xdg-base-directories = true;

        trusted-users = mkDarwinDefault ([
          "root"
          (
            if (isLinux) then
              "@wheel"
            else if (isDarwin) then
              "@admin"
            else
              abort "unsupported OS ${pkgs.stdenv.targetPlatform.config}"
          )
        ]);

        extra-substituters = mkDarwinDefault substituters;
        extra-trusted-substituters = mkDarwinDefault substituters;
        extra-trusted-public-keys = mkDarwinDefault [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          # nix-node by fontis
          "fontis.cachix.org-1:r6CU2oXo4iozCVo09V+hjJSpFlbUxQW/rDHYlLJ03Og="
          # claude-code-nix
          "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
          # codex-cli-nix
          "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
          # nixos-raspberrypi
          "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
        ];

        min-free = mkDarwinDefault (512 * 1024 * 1024);
        max-free = mkDarwinDefault (3000 * 1024 * 1024);

        builders-use-substitutes = mkDarwinDefault true;
      };

    # Entries here make package repos available via `nix shell <name>#<pkg>`
    registry = {
      stable.flake =
        if (os == "darwin") then inputs.nixpkgs-darwin-stable else inputs.nixpkgs-linux-stable;
      unstable.flake = inputs.nixpkgs-unstable;
      latest.to = {
        type = "github";
        owner = "nixos";
        repo = "nixpkgs";
        # TODO: figure out how to specify `nixos-unstable` branch
      };

      node.to = {
        type = "github";
        owner = "fontis";
        repo = "nix-node";
      };
    };

    extraOptions = lib.mkIf hasGithubToken githubTokenInclude;
  };

  # nix.extraOptions is not written when nix-darwin's Nix management is
  # disabled. Keep the SOPS-generated access token outside the Nix store and
  # include it from Determinate's custom configuration instead.
  environment.etc."nix/nix.custom.conf".text = lib.mkIf (isDarwin && hasGithubToken) (
    lib.mkAfter githubTokenInclude
  );

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # Stores the git commit the current system config was built from
  system.configurationRevision =
    let
      rev =
        if (inputs.self ? dirtyRev) then
          inputs.self.dirtyRev
        else if (inputs.self ? rev) then
          inputs.self.rev
        else
          null;
    in
    lib.mkIf (rev != null) rev;
}
