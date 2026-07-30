{ modulesPath, pkgs, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    ../../../modules/defaults/nix.nix

    ./bcachefs.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
    tmux
  ];
}
