{
  config,
  pkgs,
  lib,
  ...
}:

let

  cfg = config.programs._1password-cli;

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "programs" "_1password-cli" "gid" ] ''
      A preallocated GID will be used instead.
    '')
  ];

  options = {
    programs._1password-cli = {
      enable = lib.mkEnableOption "the 1Password CLI tool";

      package = lib.mkPackageOption pkgs "1Password CLI" {
        default = [ "_1password-cli" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    # users.groups.onepassword-cli.gid = config.ids.gids.onepassword-cli;

    # security.wrappers = {
    #   "op" = {
    #     source = "${lib.getExe cfg.package}";
    #     owner = "root";
    #     group = "onepassword-cli";
    #     setuid = false;
    #     setgid = true;
    #   };
    # };
  };
}
