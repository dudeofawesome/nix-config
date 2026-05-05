{
  os,
  lib,
  doa-lib,
  config,
  ...
}:
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

  programs = {
    kubectl.enable = true;
    ssh.enableDefaultConfig = false; # hides deprecation warning
  };
}
