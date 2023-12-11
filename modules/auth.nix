{ users, pkgs, ... }:
{
  users = {
    mutableUsers = false;

    users = builtins.mapAttrs
      (key: val: {
        description = val.fullName;
        isNormalUser = true;

        home = "/home/${key}";
        shell = if (val ? shell) then pkgs."${val.shell}" else pkgs.fish;
        group = key;
        extraGroups = if (val ? groups) then val.groups else [
          "wheel"
          "docker"
        ];

        openssh.authorizedKeys.keys = val.openssh.authorizedKeys.keys;
      })
      users;

    groups = builtins.mapAttrs (key: val: { }) users;
  };

  # Don't require password for sudo.
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    PermitRootLogin = "no";

    # disable password authentication
    PasswordAuthentication = false;
    # challengeResponseAuthentication = false;
    KbdInteractiveAuthentication = false;

    X11Forwarding = false;
  };
  services.eternal-terminal.enable = true;
}
