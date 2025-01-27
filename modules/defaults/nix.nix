{
  pkgs,
  lib,
  os,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  doa-lib = import ../../lib;
in
{
  imports = [ (doa-lib.try-import ./nix.${os}.nix) ];

  nix = {
    package = pkgs.nix;

    gc =
      {
        automatic = true;
        options = lib.mkDefault "--delete-older-than 30d";
      }
      // (
        if (isLinux) then
          {
            dates = lib.mkDefault "weekly";
          }
        else
          {
            interval.Day = lib.mkDefault 7;
          }
      );

    optimise =
      {
        automatic = lib.mkDefault true;
      }
      // (
        if (isLinux) then
          {
            dates = lib.mkDefault [ "03:45" ];
          }
        else
          {
            interval = lib.mkDefault {
              Hour = 4;
              Minute = 15;
            };
          }
      );

    # disable the nix-channel command, which leads to non-reproducible envs
    channel.enable = false;

    settings = {
      experimental-features = "nix-command flakes";

      trusted-users = lib.mkDefault ([
        "root"
        (
          if (isLinux) then
            "@wheel"
          else if (isDarwin) then
            "@admin"
          else
            abort
        )
      ]);

      substituters = lib.mkDefault [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        # nix-node by fontis
        "https://fontis.cachix.org/"
      ];

      trusted-public-keys = lib.mkDefault [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # nix-node by fontis
        "fontis.cachix.org-1:r6CU2oXo4iozCVo09V+hjJSpFlbUxQW/rDHYlLJ03Og="
      ];

      min-free = lib.mkDefault (512 * 1024 * 1024);
      max-free = lib.mkDefault (3000 * 1024 * 1024);

      builders-use-substitutes = lib.mkDefault true;
    };

    registry."node".to = {
      type = "github";
      owner = "fontis";
      repo = "nix-node";
    };
  };

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
