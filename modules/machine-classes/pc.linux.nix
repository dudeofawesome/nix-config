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
    ../configurable/headful/gnome.nix
  ];

  environment = {
    systemPackages =
      with pkgs-unstable;
      [
        # sublime4
        sunshine
      ]
      ++ (
        if (arch == "x86_64") then
          [
            cider
          ]
        else
          [ ]
      );
  };
}
