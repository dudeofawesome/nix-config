{ users, config, lib, pkgs, ... }:
let
  userSettings = (builtins.mapAttrs (key: val: val.user) users);
in
{
  config =
    with pkgs.stdenv.targetPlatform;
    {
      users = {
        mutableUsers = false;

        users = builtins.mapAttrs
          (key: val: {
            description = val.fullName;
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets.${"users/${key}/hashedPassword"}.path;

            home = "/${if isLinux then "home" else "Users"}/${key}";
            shell = if (val ? shell) then pkgs."${val.shell}" else pkgs.fish;
            group = key;
            extraGroups =
              if (val ? groups) then
                val.groups else
                [
                  "wheel"
                  "docker"
                ];

            openssh.authorizedKeys.keys = val.openssh.authorizedKeys.keys;
          })
          userSettings;

        groups = builtins.mapAttrs (key: val: { }) userSettings;
      };

      # Don't require password for sudo.
      security.sudo.wheelNeedsPassword = false;

      # Enable the OpenSSH daemon.
      services = {
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
    };
}
