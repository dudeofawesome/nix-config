{ pkgs, ... }:
{
  name = "nix-config";

  packages = with pkgs; [
    actionlint
    ipmitool
    renovate
  ];

  scripts = {
    ipmi.exec = ./scripts/ipmi.sh;
  };
}
