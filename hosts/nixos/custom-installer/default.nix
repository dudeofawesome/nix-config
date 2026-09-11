{
  config,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  # Hash the flake source, including dirty tracked changes, without depending on
  # the system derivation (which itself depends on the ISO label in the initrd).
  installerId = builtins.substring 0 16 (builtins.hashString "sha256" (toString inputs.self.outPath));

  # Upstream GRUB searches every disk for a shared marker. Give the marker the
  # same identity as the ISO label, in both its creation and every menu search.
  # Scope this runCommand wrapper to the ISO module so both the ISO tree and
  # embedded EFI image consume the same patched EFI directory.
  patchedIsoModule =
    {
      config,
      lib,
      utils,
      pkgs,
      ...
    }@args:
    import "${modulesPath}/installer/cd-dvd/iso-image.nix" (
      args
      // {
        pkgs = pkgs // {
          runCommand =
            name: env: script:
            pkgs.runCommand name env (
              if name == "efi-directory" then
                assert lib.assertMsg (lib.hasInfix "/EFI/nixos-installer-image" script)
                  "The upstream ISO module changed; review the custom installer's GRUB marker patch.";
                builtins.replaceStrings [ "/EFI/nixos-installer-image" ] [ "/EFI/${config.isoImage.volumeID}" ]
                  script
              else
                script
            );
        };
      }
    );

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
  disabledModules = [ "installer/cd-dvd/iso-image.nix" ];

  imports = [
    patchedIsoModule
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    ../../../modules/defaults/nix.nix

    ./bcachefs.nix
    ./ssh.nix
  ];

  environment.systemPackages = with pkgs; [
    tmux
    clevis
    keyutils
    sbctl
  ];

  programs.fish.enable = true;
  users.users.nixos.shell = pkgs.fish;
  users.users.root.shell = pkgs.fish;

  # nix.channel.enable does not disable the installer's bundled channel.
  # Avoid creating root channel profiles that nixos-install copies to the target.
  system.installer.channel.enable = false;

  # ISO9660 volume IDs must fit in 32 characters (this is 29).
  isoImage.volumeID = "doa-installer-${installerId}";

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
