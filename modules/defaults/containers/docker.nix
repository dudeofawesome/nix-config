{
  pkgs,
  lib,
  config,
  ...
}:
let
  nvidia_enable = builtins.elem "nvidia" config.boot.kernelModules;
in
{
  config = lib.mkIf config.virtualisation.docker.enable {
    environment.systemPackages = with pkgs; [
      docker
    ];

    # Enable Docker daemon.
    virtualisation.docker = {
      enableNvidia = nvidia_enable;
      # TODO: this might not be necessary
      # extraOptions = "--default-runtime=nvidia";
      autoPrune.enable = true;
    };
  };
}
