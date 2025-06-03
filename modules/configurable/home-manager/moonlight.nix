{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.moonlight;
in
{
  options =
    let
      inherit (lib)
        mkEnableOption
        mkOption
        mkPackageOption
        types
        ;
    in
    {
      programs.moonlight = {
        enable = mkEnableOption "Moonlight";
        package = mkPackageOption pkgs "moonlight-qt" { };

        resolution = mkOption {
          # TODO: support "native" & "custom"
          type = types.enum [
            "720"
            "1080"
            "1440"
            "2160"
          ];
          default = "720";
          example = "1440";
          description = ''
            The resolution to stream at.
          '';
        };
        fps = mkOption {
          type = types.int;
          default = 60;
          example = 120;
          description = ''
            The framerate to stream at.
          '';
        };
        unlockBitrate = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to enable extremely high bitrates for use with Sunshine.
          '';
        };
        bitrate = mkOption {
          type = types.number;
          default = 10;
          example = 30;
          description = ''
            The video bitrate to stream at, in Mbps.
          '';
        };
        vsync = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = ''
            Whether or not to enable V-Sync support.
          '';
        };
        framePacing = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to enable framepacing to reduce stutter.
          '';
        };
        hdr = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to enable HDR support.
          '';
        };
        yuv444 = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to enable YUV 4:4:4 support.
          '';
        };

        muteHostAudio = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = ''
            Whether or not to mute audio on host while streaming.
          '';
        };
        muteOnFocusLoss = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to mute audio on client when focus is lost.
          '';
        };

        reverseScroll = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to
          '';
        };
        # multicontroller = mkOption {
        #   type = types.bool;
        #   default = false;
        #   example = true;
        #   description = ''
        #     Whether or not to enable framepacing to reduce stutter.
        #   '';
        # };
        captureSystemKeys = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to
          '';
        };
        gamepadMouse = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to
          '';
        };
        # mouseacceleration = mkOption {
        #   type = types.bool;
        #   default = false;
        #   example = true;
        #   description = ''
        #     Whether or not to enable framepacing to reduce stutter.
        #   '';
        # };
        swapFaceButtons = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to
          '';
        };
        backgroundGamepad = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to
          '';
        };

        showPerformanceOverlay = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to show the performance overlay by default.
          '';
        };
        connectionWarnings = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = ''
            Whether or not to show connection quality warnings.
          '';
        };

        quitHostAppAfterEnd = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to quit the streamed app on the host after ending the stream.
          '';
        };
        keepAwake = mkOption {
          type = types.bool;
          default = false;
          example = true;
          description = ''
            Whether or not to keep the display awake while streaming.
          '';
        };
        # gameopts = mkOption {
        #   type = types.bool;
        #   default = false;
        #   example = true;
        #   description = ''
        #     Whether or not to optimize game settings for streaming.
        #   '';
        # };
        # richpresence
        # mdns
      };
    };

  config =
    let
      inherit (lib) mkIf;
      inherit (pkgs.stdenv.targetPlatform) isDarwin;

      cfg = config.programs.moonlight;
    in
    mkIf (cfg.enable && isDarwin) {
      home.packages = [ cfg.package ];

      targets.darwin.defaults = {
        "com.moonlight-stream.Moonlight" = {
          width =
            {
              "720" = 1280;
              "1080" = 1920;
              "1440" = 2560;
              "2160" = 3840;
            }
            .${cfg.resolution};
          height = lib.toInt cfg.resolution;
          fps = cfg.fps;
          unlockbitrate = cfg.unlockBitrate;
          bitrate = cfg.bitrate * 1000;
          vsync = cfg.vsync;
          framepacing = cfg.framePacing;
          hdr = cfg.hdr;
          yuv444 = cfg.yuv444;

          hostaudio = cfg.muteHostAudio;
          muteonfocusloss = cfg.muteOnFocusLoss;

          reversescroll = cfg.reverseScroll;
          # multicontroller = cfg.multicontroller;
          capturesyskeys = if cfg.captureSystemKeys then 1 else 0;
          gamepadmouse = cfg.gamepadMouse;
          # mouseacceleration = cfg.mouseacceleration;
          swapfacebuttons = cfg.swapFaceButtons;
          backgroundgamepad = cfg.backgroundGamepad;

          showperfoverlay = cfg.showPerformanceOverlay;
          connwarnings = cfg.connectionWarnings;

          quitAppAfter = cfg.quitHostAppAfterEnd;
          keepawake = cfg.keepAwake;
          # gameopts = cfg.gameopts;
          # richpresence = cfg.richpresence;
          # mdns = cfg.mdns;
        };
      };
    };
}
