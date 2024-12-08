{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.apple.iCal" = {
        "TimeZone support enabled" = true;
        "number of hours displayed" = 10;
        "Default duration in minutes for new event" = 30.0;
        CalUICanvasOccurrenceFontSize = 10.0;
        ShowDeclinedEvents = 1;
      };
    };
  };
}
