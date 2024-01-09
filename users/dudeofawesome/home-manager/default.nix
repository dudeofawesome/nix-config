{ machine-class, pkgs, lib, osConfig, config, ... }:
{
  imports = [
    ../../../modules/defaults/home-manager
    ./browsers.nix
    ./editors.nix
    ./shells.nix
    ../../../modules/configurable/home-manager/dock.nix
  ];

  home = {
    # It is occasionally necessary for Home Manager to change configuration
    # defaults in a way that is incompatible with stateful data. This could, for
    # example, include switching the default data format or location of a file.
    #
    # The state version indicates which default settings are in effect and will
    # therefore help avoid breaking program configurations. Switching to a
    # higher state version typically requires performing some manual steps,
    # such as data conversion or moving files.
    stateVersion = "23.05"; # Did you read the comment?

    keyboard = {
      layout = "us";
      variant = "workman";
    };
  };

  # sops.secrets."hosts/nixos/monongahela/ssh-keys/dudeofawesome_nix-config/private" = {
  #   format = "yaml";
  #   sopsFile = ../../../hosts/nixos/monongahela/secrets.yaml;
  #   # path = "/home/dudeofawesome/.ssh/github_dudeofawesome_nix-config_ed25519";
  # };

  programs = {
    ssh.matchBlocks =
      let
        hostUnreachable = (host: ''host ${host} !exec "ping -c1 -q -t1 '%h' 2> /dev/null"'');
      in
      {
        "unifi".user = "root";
        "unifi-remote" = {
          match = hostUnreachable "unifi";
          hostname = "oc.orleans.io";
        };
        "monongahela".user = "dudeofawesome";
        "monongahela-remote" = {
          match = hostUnreachable "monongahela";
          proxyJump = "oc.orleans.io";
        };
        "haleakala" = {
          user = "dudeofawesome";
          hostname = "192.168.254.49";
        };
        "steamdeck".user = "deck";

        "badlands-vm".user = "dudeofawesome";
        "badlands-vm-by-ip" = {
          match = hostUnreachable "badlands-vm";
          hostname = "192.168.67.2";
        };

        "home.powell.place".user = "louis";

        "home.saldivar.io" = {
          user = "edgar";
          port = 69;
        };
        "terracompute" = {
          hostname = "192.168.4.225";
          user = "vast";
        };
        "terracompute-remote" = {
          match = hostUnreachable "192.168.4.225";
          proxyJump = "home.saldivar.io";
        };
      };

    git = {
      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";

      signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGD3VYzXLFPEC25hK7o5+NrV9cvNlyV7Y93UyAQospbw";
    };

    dock = {
      enable = true;

      apps = [
        "/Applications/Firefox.app"
        "/System/Applications/Music.app"
        "/System/Applications/Messages.app"
        "/Applications/Signal.app"
        "/Applications/Slack.app"
        "/Applications/Discord.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Notes.app"
        "/System/Applications/Reminders.app"
        "/Applications/Visual Studio Code.app"
        "/Applications/Fork.app"
        "/Applications/iTerm.app"
        "/System/Applications/System Settings.app"
      ];

      others = {
        # /Applications
        "/Applications/" = {
          fileType = "1";
          arrangement = "1";
          displayAs = "1";
          showAs = "2";
          arrangement2 = "1";
        };
        # ~/Downloads
        "/Users/'$(whoami)'/Downloads/" = {
          fileType = "2";
          arrangement = "1";
          displayAs = "0";
          showAs = "1";
          arrangement2 = "2";
        };
      };
    };
  };

  # services.home-manager.autoUpgrade.enable = true;
  # specialisation.linux.configuration = {};

  targets = {
    darwin = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
      search = "DuckDuckGo";
    };
  };

  # TODO: does this path data work at all?
  home.activation.setFinickyConfigLoc = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin ''
    # set Finicky's config location here, instead of above because home-manager doesn't support plist's type "data"
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD defaults write net.kassett.finicky config_location_bookmark -data 626F6F6BE8040000000004103000000000000000000000000000000000000000000000000000000000000000000000000804000003000000010100006E697800050000000101000073746F7265000000270000000101000061666C786779367638336A6D69697678763570796A6B6C31326368386B3870302D736F7572636500080000000101000073657474696E67730B000000010100002E66696E69636B792E6A73001400000001060000040000001000000020000000500000006000000008000000040300000200000000000000080000000403000021000000000000000800000004030000079C0C00000000000800000004030000239C0C00000000000800000004030000AFA60C0000000000140000000106000090000000A0000000B0000000C0000000D00000000800000000040000C1CD27E43F800000180000000102000001000000000000000F0000000000000000000000000000000C0000000109000066696C653A2F2F2F6E69782F09000000010100004E69782053746F726500000008000000040300000050A11B73000000080000000004000041C54424D0823224240000000101000046424642384633372D443038442D344442392D423044302D34423334353641373637354318000000010200008500000001000000EF13000001000000000000000000000004000000010100002F6E6978080000000109000066696C653A2F2F2F0C000000010100004D6163696E746F7368204844080000000004000041C52EA85B000000240000000101000036453335423742382D313343422D343942422D383735342D41384241463630344145464418000000010200008100000001000000EF13000001000000000000000000000001000000010100002F00000060000000FEFFFFFF00F000000000000007000000022000004C0200000000000005200000CC0100000000000010200000DC0100000000000011200000000200000000000012200000540100000000000013200000F001000000000000202000002C02000000000000040000000303000000F000000400000003030000010000000400000003030000000000001800000001060000C0020000CC020000D8020000D8020000D8020000D8020000F900000001020000626538393237353633353033313164366437323437636130656535623132643037626135393766623235323735656263356530373462363733346363663062383B30303B30303030303030303B30303030303030303B30303030303030303B303030303030303030303030303032303B636F6D2E6170706C652E6170702D73616E64626F782E726561642D77726974653B30313B30313030303030663B303030303030303030303063396332343B30313B2F6E69782F73746F72652F61666C786779367638336A6D69697678763570796A6B6C31326368386B3870302D736F757263652F73657474696E67732F2E66696E69636B792E6A7300000000A8000000FEFFFFFF01000000580200000D00000004100000740000000000000005100000E000000000000000101000000C0100000000000040100000FC0000000000000000200000E40200000000000002200000C001000000000000052000002C0100000000000010200000400100000000000011200000740100000000000012200000540100000000000013200000640100000000000020200000A00100000000000080F000000403000000000000
  '';
}
