{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.dock;

  othersOpts =
    { name, config, ... }:
    {
      options = {
        path = mkOption {
          type = types.str;
          description = lib.mdDoc ''
            The path to a `.app` directory.
          '';
        };

        fileType = mkOption {
          type = with types; nullOr str;
          default = 2;
          description = lib.mdDoc ''
            a
          '';
        };

        arrangement = mkOption {
          type = with types; nullOr str;
          default = 1;
          description = lib.mdDoc ''
            a
          '';
        };

        displayAs = mkOption {
          type = with types; nullOr str;
          default = 0;
          description = lib.mdDoc ''
            a
          '';
        };

        showAs = mkOption {
          type = with types; nullOr str;
          default = 1;
          description = lib.mdDoc ''
            a
          '';
        };

        arrangement2 = mkOption {
          type = with types; nullOr str;
          default = 2;
          description = lib.mdDoc ''
            a
          '';
        };
      };

      config = {
        path = mkDefault name;
      };
    };
in
{
  options = {
    programs.dock = {
      enable = mkEnableOption "Set Darwin Dock items";

      apps = mkOption {
        default = [ ];
        type = types.listOf types.str;
        example = [ "/Applications/iTerm.app" ];
        description = lib.mdDoc ''
          Paths to `.app`s to put in the Dock.
        '';
      };

      others = mkOption {
        default = { };
        type = with types; attrsOf (submodule othersOpts);
        example = {
          alice = {
            plaintextPasswordFile = "/secrets/alice";
          };
        };
        description = lib.mdDoc ''
          Additional user accounts to be created automatically by the system.
          This can also be used to set options for root.
        '';
      };
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.targetPlatform.isDarwin) {
    home.activation.dockApps = ''
      function createTile() {
        echo "<dict>"
        echo "  <key>tile-data</key>"
        echo "  <dict>"
        echo "    <key>file-data</key>"
        echo "    <dict>"
        echo "      <key>_CFURLString</key>"
        echo "      <string>$1</string>"
        echo "      <key>_CFURLStringType</key><integer>0</integer>"
        echo "    </dict>"
        echo "  </dict>"
        echo "</dict>"
      }

      function setDockApps() {
        # clear dock
        defaults write com.apple.dock persistent-apps -array ""

        ${concatMapStringsSep ";\n" (
          path: ''defaults write com.apple.dock persistent-apps -array-add "$(createTile '${path}')"''
        ) cfg.apps}
      }

      PATH="/usr/bin:$PATH" run setDockApps
    '';

    home.activation.dockDirs = ''
      function createDirTile() {
        echo "<dict>"
        echo "  <key>tile-data</key>"
        echo "  <dict>"
        echo "    <key>file-data</key>"
        echo "    <dict>"
        echo "      <key>_CFURLString</key>"
        echo "      <string>$1</string>"
        echo "      <key>_CFURLStringType</key><integer>0</integer>"
        echo "    </dict>"
        echo "    <key>file-type</key>"
        echo "    <integer>$2</integer>"
        echo "    <key>arrangement</key>"
        echo "    <integer>$3</integer>"
        echo "    <key>displayas</key>"
        echo "    <integer>$4</integer>"
        echo "    <key>showas</key>"
        echo "    <integer>$5</integer>"
        echo "    <key>arrangement</key>"
        echo "    <integer>$6</integer>"
        echo "  </dict>"
        echo "  <key>tile-type</key>"
        echo "  <string>directory-tile</string>"
        echo "</dict>"
      }

      function setDockDirs() {
        # clear dock
        defaults write com.apple.dock persistent-others -array ""

        ${concatStringsSep ";\n" (
          mapAttrsToList (
            key: val:
            ''defaults write com.apple.dock persistent-others -array-add "$(createDirTile '${val.path}' ${val.fileType} ${val.arrangement} ${val.displayAs} ${val.showAs} ${val.arrangement2})"''
          ) cfg.others
        )}
      }

      PATH="/usr/bin:$PATH" run setDockDirs
    '';

    # restart Dock to show updates
    home.activation.dockRestart = hm.dag.entryAfter [
      "dockApps"
      "dockDirs"
    ] ''run /usr/bin/killall Dock'';
  };
}
