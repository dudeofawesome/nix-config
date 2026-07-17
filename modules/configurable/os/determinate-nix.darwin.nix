{
  lib,
  config,
  options,
  ...
}:
{
  config.determinateNix =
    let
      nixCfg = config.nix;
    in
    {
      enable = true;

      # Reuse the actual nix.settings definitions instead of enumerating keys.
      # Reading config.nix.settings directly also touches unset declared options.
      customSettings = lib.mkMerge options.nix.settings.definitions;

      registry = lib.mkIf (nixCfg.registry != { }) nixCfg.registry;
    };
}
