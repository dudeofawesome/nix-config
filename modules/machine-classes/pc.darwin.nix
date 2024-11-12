{ pkgs, lib, os, ... }: with lib; {
  environment = {
    systemPackages = with pkgs; [
      iina
      utm
    ];
  };

  homebrew = {
    casks =
      let
        skipSha = name: {
          inherit name;
          args = { require_sha = false; };
        };
        noQuarantine = name: {
          inherit name;
          args = { no_quarantine = true; };
        };
      in
      [
        "displaylink"
        "finicky"
        "firefox"
        "fork"
        "gitup"
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
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
    };
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          NSQuitAlwaysKeepsWindows = 1;
        };
      };
    };
  };
}
