{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      # Utilities
      lynx
      ncdu
    ];
  };
}
