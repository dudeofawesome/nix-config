{
  pkgs,
  lib,
  osConfig,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  doa-lib = import ../../../lib;
  cask-installed = doa-lib.cask-installed { inherit osConfig; };
in
{
  config = {
    home.file-json.docker-desktop-settings = {
      enable = isDarwin && (cask-installed "docker");
      target = "Library/Group Containers/group.com.docker/settings.json";
      extraConfig = {
        allowExperimentalFeatures = true;
        analyticsEnabled = false;
        autoPauseTimedActivitySeconds = 30;
        autoPauseTimeoutSeconds = 30;
        backupData = false;
        containerTerminal = "integrated";
        disableHardwareAcceleration = false;
        disableTips = true;
        disableUpdate = true;
        # diskSizeMiB = lib.mkDefault 61035;
        diskSizeMiB = 61035;
        displayedOnboarding = true;
        dockerBinInstallPath = "user";
        enableDefaultDockerSocket = true;
        extensionsEnabled = true;
        filesharingDirectories = [
          "/Users"
          "/Volumes"
          "/private"
          "/tmp"
          "/var/folders"
        ];
        kubernetesEnabled = false;
        themeSource = "system";
        useGrpcfuse = true;
        useVirtualizationFramework = true;
        # useVirtualizationFrameworkRosetta = false;
        useVirtualizationFrameworkVirtioFS = true;
        # useVpnkit = true;
      };
    };
  };
}
