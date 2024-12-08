{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.google.GoogleEarthPro" = {
        FlySpeed = 3.946;
        mouseWheelSpeed = 1;
        GroundLevelAutoTransition = false;
        SwoopEnabled = false;
        enableTips = false;

        # rendering
        "Render.Antialiasing" = 0;
        "Render.DisableAdvancedFeatures" = false;
        "Render.ImprovedShadersEnabled" = false;
      };
    };
  };
}
