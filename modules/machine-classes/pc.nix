{ pkgs, lib, os, ... }: with lib; {
  imports = [
  ]
  ++ (if (os == "linux") then [ ./pc.linux.nix ] else [ ])
  ;

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      mitmproxy

      docker
      kubectl
      kubectx
      moonlight-qt
    ];
  };
}
