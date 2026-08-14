{
  lib,
  pkgs,
  ...
}:
let
  users = lib.pipe (builtins.readDir ../../../users) [
    (lib.filterAttrs (_: type: type == "directory"))
    (lib.mapAttrsToList (name: _: import (../../../users + "/${name}")))
  ];

  stateMount = "/persist/custom-installer";
  runtimeHostKey = "/run/custom-installer/ssh_host_ed25519_key";
in
{
  fileSystems.${stateMount} = {
    device = "/dev/disk/by-label/INSTALLER_STATE";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  systemd.services.sshd = {
    after = [ "custom-installer-ssh-host-key.service" ];
    requires = [ "custom-installer-ssh-host-key.service" ];
  };

  systemd.services.custom-installer-ssh-host-key = {
    description = "Select the custom installer's persistent SSH host key";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [
      coreutils
      gawk
      iproute2
      openssh
      util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      if mountpoint --quiet ${stateMount}; then
        keys_root="${stateMount}/ssh-host-keys"
      else
        keys_root="/run/custom-installer/ephemeral-ssh-host-keys"
        warning="INSTALLER_STATE is unavailable; SSH is using an ephemeral host key"
        echo "$warning" >&2
        echo "$warning" > /dev/console
      fi

      ip_address="$(
        ip -4 -oneline route get 1.1.1.1 \
          | awk '{ for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }'
      )"

      if [[ ! "$ip_address" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Could not determine the installer's primary IPv4 address" >&2
        exit 1
      fi

      key_directory="$keys_root/$ip_address"
      key_file="$key_directory/ssh_host_ed25519_key"
      install -d -m 0700 "$keys_root" "$key_directory" "$(dirname ${runtimeHostKey})"

      if [[ ! -s "$key_file" ]]; then
        temporary_key="$key_directory/.ssh_host_ed25519_key.$$"
        trap 'rm -f "$temporary_key" "$temporary_key.pub"' EXIT
        ssh-keygen -q -t ed25519 -N "" -C "custom-installer@$ip_address" -f "$temporary_key"
        mv "$temporary_key" "$key_file"
        mv "$temporary_key.pub" "$key_file.pub"
        trap - EXIT
      fi

      if [[ ! -s "$key_file.pub" ]]; then
        ssh-keygen -y -f "$key_file" > "$key_file.pub"
      fi

      chmod 0600 "$key_file"
      chmod 0644 "$key_file.pub"
      ln -sfn "$key_file" ${runtimeHostKey}
      ln -sfn "$key_file.pub" ${runtimeHostKey}.pub
    '';
  };

  services.openssh = {
    generateHostKeys = false;
    hostKeys = [
      {
        path = runtimeHostKey;
        type = "ed25519";
      }
    ];
  };

  users.users.nixos.openssh.authorizedKeys.keys = lib.pipe users [
    (map (user: user.user.openssh.authorizedKeys.keys))
    lib.flatten
  ];
}
