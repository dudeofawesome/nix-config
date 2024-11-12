{ pkgs, os, ... }:
with pkgs.stdenv.targetPlatform;
let doa-lib = import ../../lib; in
{
  imports = [ (doa-lib.try-import ./nix.${os}.nix) ];

  nix = {
    package = pkgs.nix;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    } // (if (isLinux) then {
      dates = "weekly";
    } else {
      interval.Day = 7;
    });

    optimise = {
      automatic = true;
    } // (if (isLinux) then {
      dates = [ "03:45" ];
    } else {
      interval = {
        Hour = 4;
        Minute = 15;
      };
    });

    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';

    # disable the nix-channel command, which leads to non-reproducible envs
    channel.enable = false;

    settings = {
      trusted-users =
        if (isLinux) then [ "root" "@wheel" ]
        else if (isDarwin) then [ "root" "@admin" ]
        else abort;

      substituters = [
        "https://cache.nixos.org/"
        # nix-node by fontis
        "https://fontis.cachix.org/"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        # nix-node by fontis
        "fontis.cachix.org-1:r6CU2oXo4iozCVo09V+hjJSpFlbUxQW/rDHYlLJ03Og="
      ];
    };

    registry."node".to = {
      type = "github";
      owner = "fontis";
      repo = "nix-node";
    };
  };

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}
