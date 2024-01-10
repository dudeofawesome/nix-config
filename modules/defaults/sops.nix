{ os, pkgs, lib, ... }:
with pkgs.stdenv.targetPlatform;
{
  environment.systemPackages = with pkgs; [
    age
    sops
    ssh-to-age
  ];
} // (if (os == "linux") then {
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
} else { })
