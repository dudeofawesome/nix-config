{
  pkgs-unstable,
  lib,
  os,
  ...
}:
with lib;
{
  environment = {
    systemPackages = with pkgs-unstable; [
      iina
      utm
    ];
  };

  homebrew = {
    casks =
      let
        skipSha = name: {
          inherit name;
          args = {
            require_sha = false;
          };
        };
        noQuarantine = name: {
          inherit name;
          args = {
            no_quarantine = true;
          };
        };
      in
      [
        "firefox"
        "google-chrome"
        (noQuarantine "qlcolorcode")
        (noQuarantine "quicklook-video")
      ];
    masApps = {
      # "AdGuard for Safari" = 1440147259;
      # "Amphetamine" = 937984704;
      # "Xcode" = 497799835;
    };
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
      };
    };
  };
}
