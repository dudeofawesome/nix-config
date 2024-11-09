{ pkgs, lib, os, ... }: with lib; {
  imports = [
    (if (builtins.pathExists ./pc.${os}.nix) then ./pc.${os}.nix else { })
    ../defaults/containers/k8s/user-utils.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      docker
      # mitmproxy
      moonlight-qt
      watch
    ];
  };
}
