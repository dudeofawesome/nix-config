{ config, ... }:
{
  imports = [
    ./apple-calendar.nix
    ./apple-contacts.nix
    ./apple-music.nix
    ./apple-mail.nix
    ./control-center.nix
    ./disk-utility.nix
    ./dock.nix
    ./file-merge.nix
    ./finder.nix
    ./keyboard.nix
    ./mouse.darwin.nix
    ./script-editor.nix
    ./spotlight.nix
    ./window-manager.darwin.nix
  ];

  targets.darwin.copyApps = {
    enable = true;
    directory = "${config.home.homeDirectory}/Applications/Home Manager Apps";
    # disable checks as they're bugged
    #   https://github.com/nix-community/home-manager/issues/8336
    enableChecks = false;
  };
  targets.darwin.linkApps.enable = false;
}
