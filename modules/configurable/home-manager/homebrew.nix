{ lib, ... }:
{
  options =
    let
      inherit (lib) mkOption mkEnableOption types;
    in
    {
      homebrew = {
        enable = mkEnableOption "homebrew";

        casks = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "wget" ];
          description = ''
            List of Homebrew casks to install.
          '';
        };
      };
    };

  # config = { };
}
