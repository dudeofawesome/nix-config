{ pkgs-unstable }:
{
  # boot.kernelPackages = pkgs.linuxPackages; # (this is the default) some amdgpu issues on 6.10

  programs = {
    gamescope = {
      enable = true;
      package = pkgs-unstable.gamescope;

      capSysNice = true;

      args = [
        "--adaptive-sync" # VRR support
        "--hdr-enabled"
        "--mangoapp" # performance monitoring overlay
        "--rt"
        "--steam"
      ];
      env = {
        MANGOHUD = "1";
        # TODO: write config to ~/.config/MangoHud/MangoHud.conf
        MANGOHUD_CONFIG = builtins.concatStringsSep "," [
          "fps_text"
        ];
      };
    };
    steam.gamescopeSession.enable = true;
  };

  environment.systemPackages = pkgs-unstable.mangohud;
}
