{
  doa-lib,
  pkgs,
  os,
  ...
}:
{
  imports = [
    (doa-lib.try-import ./server.${os}.nix)
  ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      lynx
      ncdu
    ];
  };
}
