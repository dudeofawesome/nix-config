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
    };
  };
  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;
}
