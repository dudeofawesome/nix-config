{ lib, ... }:
{
  options.hardware.bmc.onePassword = {
    account = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "orleans.1password.com";
      description = ''
        1Password account holding this host's baseboard management controller
        (iDRAC / IPMI) credentials — any identifier `op --account` accepts (a
        sign-in address or an account ID).
      '';
    };

    item = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "scvtze3rk472qfoybwj43arhxi";
      description = ''
        1Password item UUID for this host's baseboard management controller
        (iDRAC / IPMI) credentials.

        Read at runtime (via `nix eval`) by scripts/ipmi.sh and scripts/redfish.sh
        to locate the credentials for this host. The item must contain `host`,
        `username`, and `password` fields; redfish.sh's default verified mode
        also reads a `certificate` field holding the controller's PEM certificate.
      '';
    };
  };
}
