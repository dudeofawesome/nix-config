{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.docker-desktop;
in
{
  options = {
    programs.docker-desktop = {
      enable = lib.mkEnableOption "the docker CLI";

      # package = lib.mkPackageOption pkgs "Docker Desktop" {
      #   default = [ "docker-desktop" ];
      # };

      settings = lib.mkOption {
        description = ''Settings for Docker Desktop's settings.json'';
        type = lib.types.attrs;
        default = { };
        example = {
          allowExperimentalFeatures = true;
          useVirtualizationFrameworkVirtioFS = true;
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    # home.packages = [ cfg.package ];

    programs.docker-client.enable = true;

    home = {
      file-json.docker-desktop-settings = lib.mkIf (cfg.settings != { }) {
        inherit (cfg) enable;
        target =
          if (pkgs.stdenv.targetPlatform.isDarwin) then
            "Library/Group Containers/group.com.docker/settings.json"
          else
            abort;
        extraConfig = cfg.settings;
      };

      # TODO: figure out a better solution
      # This cleans up a bunch of symlinks the macOS Docker Desktop app makes which
      #   override the versions we install with Nix
      activation.cleanupDockerDesktopBin =
        let
          bin_path =
            with config.programs.docker-desktop.settings;
            if (dockerBinInstallPath == "user") then
              "/usr/local/bin/"
            else
              abort "What is the correct path for '${dockerBinInstallPath}'?";
        in
        lib.mkIf (pkgs.stdenv.targetPlatform.isDarwin) (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            echo -e "\033[0;33mUsing sudo to clean up docker desktop's unwanted binaries:\033[0m"
            pushd "${bin_path}" > /dev/null
            run /usr/bin/sudo rm -f \
              docker \
              docker-compose \
              docker-index \
              kubectl \
              kubectl.docker \
              ;
          ''
        );
    };
  };
}
