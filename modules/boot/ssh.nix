{ users, builtins, ... }: with builtins {
  boot.initrd = {
    # Enable SSH in initrd. Useful for unlocking LUKS remotely.
    network.enable = true;
    network.ssh = {
      enable = true;
      port = 22;
      authorizedKeys = flatten mapAttrs (key: val: val.openssh.authorizedKeys.keys) users;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # TODO: add a NIC module
    ];
  };
}
