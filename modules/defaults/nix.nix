{ pkgs, ... }:
with pkgs.stdenv.targetPlatform;
{
  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';

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
    };

    registry."node".to = {
      type = "github";
      owner = "fontis";
      repo = "nix-node";
    };
  }
  // (if (isDarwin) then {
    linux-builder = {
      enable = true;
      maxJobs = 10;
    };
  } else { })
  ;

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}