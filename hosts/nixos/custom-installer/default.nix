{ modulesPath, pkgs, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    ../../../modules/defaults/nix.nix

    ./bcachefs.nix
    ./ssh.nix
  ];

  environment.systemPackages = with pkgs; [
    fish
    tmux
    clevis
    keyutils
    sbctl
  ];

  # https://wiki.nixos.org/wiki/Creating_a_NixOS_live_CD#Building_faster
  # TODO: investigate zstd, eg: `zstd -Xcompression-level 3`
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
