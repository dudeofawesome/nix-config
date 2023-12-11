{ users, lib, pkgs, ... }:
with lib;
with pkgs.stdenv.targetPlatform;
{
  users = {
    mutableUsers = mkIf isLinux false;

    users = builtins.mapAttrs
      (key: val: {
        description = val.fullName;
        isNormalUser = mkIf isLinux true;

        home = "/${if isLinux then "home" else "Users"}/${key}";
        shell = if (val ? shell) then pkgs."${val.shell}" else pkgs.fish;
        group = mkIf isLinux key;
        extraGroups =
          if (val ? groups) then
            mkIf isLinux val.groups else
            mkIf isLinux [
              "wheel"
              "docker"
            ];

        openssh.authorizedKeys.keys = val.openssh.authorizedKeys.keys;
      })
      users;

    groups = mkIf isLinux builtins.mapAttrs (key: val: { }) users;
  };

  # Don't require password for sudo.
  security = mkIf isLinux {
    sudo.wheelNeedsPassword = false;
  };

  # Enable the OpenSSH daemon.
  services = mkIf isLinux {
    openssh = {
      enable = true;

      settings = {
        PermitRootLogin = "no";

        # disable password authentication
        PasswordAuthentication = false;
        # challengeResponseAuthentication = false;
        KbdInteractiveAuthentication = false;

        X11Forwarding = false;
      };
    };

    eternal-terminal.enable = true;
  };
}
