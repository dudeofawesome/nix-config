{ pkgs, lib, os, ... }: with lib; {
  imports = [
    ../defaults/containers/k8s/user-utils.nix
  ]
  ++ (if (os == "linux") then [ ./pc.linux.nix ] else [ ])
  ;

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      mitmproxy

      docker
      moonlight-qt
    ];
  };
}
