{
  pkgs,
  lib,
  config,
  osConfig,
  hostname,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  has_1password =
    config.programs._1password-cli.enable
    || config.programs._1password-gui.enable
    || (isLinux && (osConfig.programs._1password.enable || osConfig.programs._1password-gui.enable));
in
{
  home = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = lib.mkDefault "23.05"; # Did you read the comment?

    preferXdgDirectories = true;
  };

  xdg.configFile.prettier = {
    target = ".prettierrc.js";
    source = "${pkgs.dotfiles.dudeofawesome}/home/.config/.prettierrc.js";
  };

  programs = {
    ssh = {
      enable = true;

      matchBlocks = {
        "*" =
          if (has_1password) then
            {
              # TODO: switch to this (instead of `extraConfig`) once https://github.com/nix-community/home-manager/issues/4134 is solved
              # IdentityAgent = lib.mkDefault (
              #   if (isDarwin) then "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
              #   else if (isLinux) then "~/.1password/agent.sock"
              #   else abort
              # );
            }
          else
            {
              identityFile = lib.mkDefault "~/.ssh/${hostname}_ed25519";
              identitiesOnly = lib.mkDefault true;
            };

        "git" = {
          match = "host *git*,*bitbucket*";
          user = "git";
        };
      };

      extraConfig = ''
        ${
          if (has_1password) then
            (
              "IdentityAgent = ${
                if (isDarwin) then
                  ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
                else if (isLinux) then
                  ''"~/.1password/agent.sock"''
                else
                  abort
              }"
            )
          else
            ""
        }
      '';
    };

    doa-system-clock.enable = true;
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = lib.mkIf isDarwin {
      # keybindings = {
      #   "~f" = "moveWordForward:";
      # };

      defaults = {
        # "com.apple.Terminal" = { };

        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 1;
        };

        "com.apple.networkConnect" = {
          VPNShowTime = 1;
        };

        "com.spotify.client".AutoStartSettingIsHidden = 0;

        "com.apple.Safari".IncludeDevelopMenu = true;
      };
    };
  };

  home.activation.zzActivateSettings = lib.mkIf isDarwin ''
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    run /usr/bin/killall Dock ControlCenter
  '';
}
