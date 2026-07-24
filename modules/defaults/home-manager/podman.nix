{
  lib,
  osConfig,
  ...
}:
{
  programs.podman-desktop = {
    enable = lib.mkDefault (
      osConfig.virtualisation.podman ? desktop && osConfig.virtualisation.podman.desktop.enable
    );
    extraConfig = {
      "telemetry.enabled" = false;
      "preferences.login.start" = false;
      "podman.setting.rosetta" = true;
      "preferences.update.reminder" = "never";
    };
  };
}
