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

    permitRootLogin = "no";

    # disable password authentication
    passwordAuthentication = false;
    # challengeResponseAuthentication = false;
    kbdInteractiveAuthentication = false;

    forwardX11 = false;
  };
  services.eternal-terminal.enable = true;
}
