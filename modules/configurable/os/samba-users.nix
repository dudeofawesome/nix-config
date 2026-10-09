{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.samba.users;

  userOpts =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.passwdEntry types.str;
          apply =
            x:
            assert (
              builtins.stringLength x < 32
              || abort "Username '${x}' is longer than 31 characters which is not allowed!"
            );
            x;
          description = ''
            The name of the user account. If undefined, the name of the
            attribute set will be used.
          '';
        };

        plaintextPasswordFile = mkOption {
          type = with types; nullOr str;
          default = cfg.users.${name}.passwordFile;
          defaultText = literalExpression "null";
          description = ''
            The full path to a file that contains the plaintext of the user's
            password. The password file is read on each system activation. The
            file should contain exactly one line, which should be the password in
            plaintext that is suitable for the `smbpasswd` command.
          '';
        };
      };

      config = {
        name = mkDefault name;
      };
    };
in
{
  options = {
    services.samba.users = {
      enable = mkEnableOption "Declarative Samba user management";

      users = mkOption {
        default = { };
        type = with types; attrsOf (submodule userOpts);
        example = {
          alice = {
            plaintextPasswordFile = "/secrets/alice";
          };
        };
        description = ''
          Additional user accounts to be created automatically by the system.
          This can also be used to set options for root.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Add the samba CLI to ensure access to `smbpasswd`.
      samba
    ];

    # create smb users
    system.activationScripts.time-machine_set-passwords = {
      # The password files usually come from sops-nix; make sure they exist first.
      deps = [ "setupSecrets" ];
      text = concatMapStringsSep "; " (
        key:
        let
          val = cfg.users.${key};
        in
        ''
          { cat '${val.plaintextPasswordFile}'; echo ""; cat '${val.plaintextPasswordFile}'; echo ""; } \
            | "${pkgs.samba}/bin/smbpasswd" -s -a '${val.name}'
        ''
      ) (builtins.attrNames cfg.users);
    };

    # users.users = builtins.mapAttrs
    #   (key: val: if config.users.users.${val.name} then { } else {
    #     name = val.name;
    #     isSystemUser = true;
    #     group = cfg.systemUser;
    #   })
    #   cfg.users;
  };
}
