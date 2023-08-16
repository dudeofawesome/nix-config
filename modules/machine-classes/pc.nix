{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      # Utilities
      mitmproxy
    ];
  };
}
