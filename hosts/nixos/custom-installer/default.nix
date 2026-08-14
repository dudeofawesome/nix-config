{
  config,
  modulesPath,
  pkgs,
  ...
}:
let
  installerState =
    pkgs.runCommand "custom-installer-state.ext4"
      {
        nativeBuildInputs = [ pkgs.e2fsprogs ];
      }
      ''
        truncate --size 64M $out
        mkfs.ext4 \
          -q \
          -L INSTALLER_STATE \
          -U 9f519f45-c5f7-4ddd-b4c1-b3f5eb7c5756 \
          -E lazy_itable_init=0,lazy_journal_init=0 \
          $out
      '';
in
{
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

  system.build.usbImage =
    pkgs.runCommand "custom-installer-usb-image"
      {
        nativeBuildInputs = [ pkgs.xorriso ];
      }
      ''
        mkdir -p $out/usb $out/nix-support

        xorriso \
          -indev ${config.system.build.isoImage}/${config.image.filePath} \
          -outdev $out/usb/custom-installer.img \
          -boot_image any replay \
          -append_partition 3 0x83 ${installerState} \
          -commit

        echo "file disk-image $out/usb/custom-installer.img" \
          > $out/nix-support/hydra-build-products
      '';
}
