{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
  ];

  # Enable Docker daemon.
  virtualisation.docker = {
    enable = false;
    # enableNvidia = true;
    # TODO: this might not be necessary
    # extraOptions = "--default-runtime=nvidia";
    autoPrune.enable = true;
  };
}
