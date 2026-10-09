# Ask for an encrypted bcachefs passphrase once per filesystem, not once per mount.
#
# NixOS creates an `unlock-bcachefs-<mountpoint>` initrd service for every
# bcachefs entry in `fileSystems` (/, /home, /nix, /tmp are separate entries when
# they are subvolumes of one filesystem). systemd gives each service and mount
# unit a private kernel keyring, so the key loaded for one mount is invisible to
# the next, and every mount prompts again. This module links the root user's
# keyring into those units, loads the key into it, and makes later services skip
# the prompt when the key is already present. The normal interactive prompt is
# kept as the fallback.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  bootFs = lib.filter (fs: fs.fsType == "bcachefs" && utils.fsNeededForBoot fs) (
    lib.attrValues config.fileSystems
  );

  firstDevice = fs: lib.head (lib.splitString ":" fs.device);
  # Key description used by the kernel and bcachefs-tools: "bcachefs:<superblock uuid>".
  uuidOf =
    fs:
    let
      dev = firstDevice fs;
    in
    if lib.hasPrefix "/dev/disk/by-uuid/" dev then
      lib.removePrefix "/dev/disk/by-uuid/" dev
    else if lib.hasPrefix "UUID=" dev then
      lib.removePrefix "UUID=" dev
    else
      null;

  unlockUnit = fs: "unlock-bcachefs-${utils.escapeSystemdPath fs.mountPoint}";
  mountUnit =
    fs: "${utils.escapeSystemdPath (lib.removeSuffix "/" ("/sysroot" + fs.mountPoint))}.mount";

  keyctl = "${pkgs.keyutils}/bin/keyctl";
  bcachefs = "${config.boot.bcachefs.package}/bin/bcachefs";
  askPassword = "${config.boot.initrd.systemd.package}/bin/systemd-ask-password";
in
{
  config = lib.mkIf (config.boot.initrd.systemd.enable && bootFs != [ ]) {
    boot.initrd.systemd = {
      storePaths = [ keyctl ];

      services = lib.listToAttrs (
        map (fs: {
          name = unlockUnit fs;
          value = {
            serviceConfig.KeyringMode = "shared";
            script =
              let
                uuid = uuidOf fs;
                skipIfLoaded = lib.optionalString (uuid != null) ''
                  if ${keyctl} search @u user "bcachefs:${uuid}" >/dev/null 2>&1; then
                    echo "bcachefs ${uuid} already unlocked"
                    exit 0
                  fi
                '';
              in
              lib.mkForce ''
                ${skipIfLoaded}
                ${askPassword} --timeout=0 "enter passphrase for bcachefs ${fs.mountPoint}" \
                  | exec ${bcachefs} unlock -k user "${firstDevice fs}"
              '';
          };
        }) bootFs
      );

      # The mount units themselves must see the shared keyring too.
      units = lib.listToAttrs (
        map (fs: {
          name = mountUnit fs;
          value = {
            overrideStrategy = "asDropin";
            text = ''
              [Mount]
              KeyringMode=shared
            '';
          };
        }) bootFs
      );
    };
  };
}
