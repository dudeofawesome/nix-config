{ pkgs, lib, ... }:
let
  workmanInputSource = {
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = 14844;
    "KeyboardLayout Name" = "Workman";
  };
in
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults = {
        NSGlobalDomain = {
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          ApplePressAndHoldEnabled = false;
          AppleKeyboardUIMode = 3;

          NSAutomaticSpellingCorrectionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;

          # NSUserDictionaryReplacementItems =
          #   map
          #     (input:
          #       {
          #         on = 1;
          #         replace = builtins.elemAt input 0;
          #         "with" = builtins.elemAt input 1;
          #       })
          #     [
          #       [ "fuck" "fuck" ]
          #       [ "suck" "suck" ]
          #       [ "fucking" "fucking" ]
          #       [ ":D" "\\Ud83d\\Ude00" ] # 😀
          #       [ ":p" "\\Ud83d\\Ude1b" ] # 😛
          #       [ "idk" "IDK" ]
          #       [ "*plusminus" "\\U00b1" ] # ±
          #       [ "gql" "GraphQL" ]
          #       [ "omw" "on my way" ]
          #       [ "*lenny" "( \\U0361\\U00b0 \\U035c\\U0296 \\U0361\\U00b0)" ] # ( ͡° ͜ʖ ͡°)
          #       [ "*tableflip" "(\\U256f\\U00b0\\U25a1\\U00b0)\\U256f\\Ufe35 \\U253b\\U2501\\U253b" ] # (╯°□°)╯︵ ┻━┻
          #       [ "*shruggie" "\\U00af\\\\_(\\U30c4)_/\\U00af" ] # ¯\_(ツ)_/¯
          #       [ "*confused" "( \\U0ca0 \\U0ca0 )" ] # ( ಠ ಠ )
          #     ];

          # NSUserKeyEquivalents = {
          #   "Look Up in Dash" = "^h";
          #   "Show Next Tab" = "@~\\U2192";
          #   "Show Previous Tab" = "@~\\U2190";
          # };
        };

        "com.apple.HIToolbox" = {
          AppleCurrentKeyboardLayoutInputSourceID = "org.sil.ukelele.keyboardlayout.workman.workman";
          AppleDefaultAsciiInputSource = workmanInputSource;
          AppleCurrentAsciiInputSource = workmanInputSource;
          AppleCurrentInputSource = workmanInputSource;
          AppleEnabledInputSources = [ workmanInputSource ];
          AppleFnUsageType = 1; # Change Input Source
          AppleInputSourceHistory = [ workmanInputSource ];
          AppleSelectedInputSources = [ workmanInputSource ];
        };
      };
    };
  };
}
