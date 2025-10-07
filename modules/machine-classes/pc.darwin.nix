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
        "displaylink"
        "finicky"
        "firefox"
        "google-chrome"
        "hex-fiend"
        "iterm2"
        "keka"
        (noQuarantine "qlcolorcode")
        (noQuarantine "qlmarkdown")
        (noQuarantine "qlstephen")
        (noQuarantine "qlvideo")
        (noQuarantine "quicklook-json")
        "sublime-text"
      ];
    masApps = {
      "AdGuard for Safari" = 1440147259;
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
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
