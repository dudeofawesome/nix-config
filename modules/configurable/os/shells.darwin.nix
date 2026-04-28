{ lib, config, ... }:
{
  # nix-darwin won't set an already-existing user's shell
  # https://daiderd.com/nix-darwin/manual/index.html#opt-users.users._name_.shell
  system.activationScripts.postActivation.text = lib.mkAfter (
    lib.pipe config.users.users [
      (lib.filterAttrs (_: user: user ? shell && user.shell != null))
      (lib.mapAttrsToList (
        name: user: ''
          /usr/bin/chsh \
            -s "${user.shell}${user.shell.shellPath}" \
            "${name}"
        ''
      ))
      (lib.concatStringsSep "\n")
    ]
  );
}
