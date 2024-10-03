{ pkgs, lib, os, ... }: with lib; {
  imports = [
    ../defaults/containers/k8s/user-utils.nix
  ]
  ++ (if (os == "linux") then [ ./pc.linux.nix ] else [ ])
  ;

  environment = {
    systemPackages = with pkgs; [
      docker
      # mitmproxy
      moonlight-qt
      gcc
      llvm
    ];
  };
}
