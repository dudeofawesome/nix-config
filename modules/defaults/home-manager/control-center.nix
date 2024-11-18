{ pkgs, lib, config, ... }: {
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."com.apple.controlcenter" = {
        "NSStatusItem Visible Clock" = true;
        "NSStatusItem Visible WiFi" = true;
        "NSStatusItem Visible Bluetooth" = true;
        "NSStatusItem Visible Sound" = true;
        "NSStatusItem Visible Battery" = true;
        # "NSStatusItem Visible Display" = false;
        # "NSStatusItem Visible FocusModes" = false;
        "NSStatusItem Visible Shortcuts" = true;
      };

      currentHostDefaults."com.apple.controlcenter" = {
        BatteryShowPercentage = true;
      };


      defaults."com.apple.systemuiserver" = {
        "NSStatusItem Visible com.apple.menuextra.vpn" = true;
        "NSStatusItem Visible com.apple.menuextra.TimeMachine" = true;

        menuExtras = [
          "/System/Library/CoreServices/Menu Extras/VPN.menu"
          "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
        ];
      };

      defaults."com.apple.Siri" = {
        StatusMenuVisible = 0;
      };

      defaults."com.apple.Spotlight" = {
        "NSStatusItem Visible Item-0" = false;
      };
    };
  };
}
