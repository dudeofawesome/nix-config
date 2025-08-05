{
  inputs,
  pkgs,
  lib,
  os,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  doa-lib = import ../../lib;

  mkDarwinDefault = lib.mkOverride 99;
in
{
  imports = [ (doa-lib.try-import ./nix.${os}.nix) ];

  nix = {
    package = pkgs.nix;

    gc = {
      automatic = true;
      options = lib.mkDefault "--delete-older-than 30d";
    }
    // (
      if (isLinux) then
        { dates = lib.mkDefault "weekly"; }
      else if (isDarwin) then
        { interval.Day = lib.mkDefault 7; }
      else
        abort "Unsupported OS"
    );

    optimise = {
      automatic = lib.mkDefault true;
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
        abort "Unsupported OS"
    );

    # disable the nix-channel command, which leads to non-reproducible envs
    channel.enable = false;

    settings = {
      experimental-features = "nix-command flakes";

      trusted-users = mkDarwinDefault ([
        "root"
        (
          if (isLinux) then
            "@wheel"
          else if (isDarwin) then
            "@admin"
          else
            abort "Unsupported OS"
        )
      ]);

      trusted-substituters = mkDarwinDefault [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        # nix-node by fontis
        "https://fontis.cachix.org/"
      ];

      trusted-public-keys = mkDarwinDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # nix-node by fontis
        "fontis.cachix.org-1:r6CU2oXo4iozCVo09V+hjJSpFlbUxQW/rDHYlLJ03Og="
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
  };

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
