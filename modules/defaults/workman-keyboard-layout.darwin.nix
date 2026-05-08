{
  lib,
  pkgs,
  ...
}:
let
  workmanInputSource = {
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = 14844;
    "KeyboardLayout Name" = "Workman";
  };
in
{
  config = {
    environment.systemPackages = [ pkgs.workman ];

    system.activationScripts.install-workman-keyboard-layout.text =
      let
        keyboardLayoutsDir = "/Library/Keyboard Layouts";
        workmanBundle = "${keyboardLayoutsDir}/Workman.bundle";
      in
      lib.mkAfter ''
        echo "installing Workman keyboard layout..."
        mkdir -p '${keyboardLayoutsDir}'
        rm -rf '${workmanBundle}'
        cp -R '${pkgs.workman}/Library/Keyboard Layouts/Workman.bundle' '${keyboardLayoutsDir}/'
        chmod -R u+w,go+rX '${workmanBundle}'
      '';

    system.defaults.CustomUserPreferences."com.apple.HIToolbox" = {
      AppleCurrentKeyboardLayoutInputSourceID = "org.sil.ukelele.keyboardlayout.workman.workman";
      AppleDefaultAsciiInputSource = workmanInputSource;
      AppleCurrentAsciiInputSource = workmanInputSource;
      AppleCurrentInputSource = workmanInputSource;
      AppleEnabledInputSources = [ workmanInputSource ];
      AppleInputSourceHistory = [ workmanInputSource ];
      AppleSelectedInputSources = [ workmanInputSource ];
    };
  };
}
