{ ... }:
{
  programs.moonlight = {
    enable = true;

    resolution = "1080";
    fps = 60;
    bitrate = 30;
    hdr = true;
    vsync = true;
    framePacing = true;

    muteOnFocusLoss = false;

    captureSystemKeys = true;
    backgroundGamepad = true;

    showPerformanceOverlay = true;
  };
}
