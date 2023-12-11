{ users, ... }:
{
  users = {
    mutableUsers = false;

    users = builtins.mapAttrs
      (key: val: {
        home = "/home/${key}";
        shell = val.shell;
      })
      users;
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
