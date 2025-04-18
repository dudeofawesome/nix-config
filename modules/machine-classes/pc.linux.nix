{
  pkgs-unstable,
  lib,
  arch,
  os,
  ...
}:
with lib;
{
  imports = [
    ../../modules/defaults/headful/gnome.nix
  ];

  environment = {
    systemPackages =
      with pkgs-unstable;
      lib.flatten [
        # sublime4
        sunshine
        (lib.optional (pkgs.stdenv.targetPlatform.isx86) cider)
      ];
  };
}
