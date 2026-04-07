{
  os,
  lib,
  config,
  ...
}:
let
  doa-lib = import ../../../lib;
in
{
  imports = [
    (doa-lib.try-import ./default.${os}.nix)

    ./editors.nix
    ./miscellaneous.nix
    ./git.nix
    ./nix
    ./shells.nix
    ./sops.nix
    ./tmux
  ];

  programs.kubectl.enable = true;

  targets.darwin.copyApps.enable = true;
  targets.darwin.copyApps.directory = "${config.home.homeDirectory}/Applications/Home Manager Apps";
  targets.darwin.linkApps.enable = false;
}
