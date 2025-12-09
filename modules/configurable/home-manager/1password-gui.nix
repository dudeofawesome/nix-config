{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.programs._1password-gui;
  tomlFormat = pkgs.formats.toml { };

in
{
  imports = [
    (lib.mkRemovedOptionModule [ "programs" "_1password-gui" "gid" ] ''
      A preallocated GID will be used instead.
    '')
  ];

  options = {
    programs._1password-gui = {
      enable = lib.mkEnableOption "the 1Password GUI application";

      # polkitPolicyOwners = lib.mkOption {
      #   type = lib.types.listOf lib.types.str;
      #   default = [ ];
      #   example = lib.literalExpression ''["user1" "user2" "user3"]'';
      #   description = ''
      #     A list of users who should be able to integrate 1Password with polkit-based authentication mechanisms.
      #   '';
      # };

      package = lib.mkPackageOption pkgs "1Password GUI" {
        default = [ "_1password-gui" ];
      };

      extraConfig = lib.mkOption {
        description = ''Extra config options for 1Password's settings.json'';
        type = lib.types.attrs;
        default = { };
        example = {
          "app.SkipArchiveAlert" = true;
          "browsers.extension.enabled" = true;
        };
      };

      sshAgentConfig = lib.mkOption {
        type = tomlFormat.type;
        default = { };
        example = lib.literalExpression ''
          "ssh-keys" = [
            { vault = "Private"; }
          ];
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/1Password/ssh/agent.toml`
          See <https://developer.1password.com/docs/ssh/agent/config/> for more info.
        '';
      };
    };
  };

  config =
    let
      # package = cfg.package.override {
      #   polkitPolicyOwners = cfg.polkitPolicyOwners;
      # };
      package = cfg.package;
    in
    lib.mkIf cfg.enable {
      home.packages =
        lib.mkIf
          # _1password-gui is broken on Darwin (it "must" be installed in /Applications)
          (!pkgs.stdenv.targetPlatform.isDarwin)
          [ package ];

      # users.groups.onepassword.gid = config.ids.gids.onepassword;

      # security.wrappers = {
      #   "1Password-BrowserSupport" = {
      #     source = "${package}/share/1password/1Password-BrowserSupport";
      #     owner = "root";
      #     group = "onepassword";
      #     setuid = false;
      #     setgid = true;
      #   };
      # };

      # TODO: can we actually configure everything we think we can?
      #   https://support.1password.com/settings-security/#considerations-for-system-administrators
      home.file-json._1password-gui-settings = lib.mkIf (cfg.extraConfig != { }) {
        inherit (cfg) enable extraConfig;
        target =
          if (pkgs.stdenv.targetPlatform.isDarwin) then
            "Library/Group Containers/2BUA8C4S2C.com.1password/Library/Application Support/1Password/Data/settings/settings.json"
          else
            ".config/1Password/settings/settings.json";
      };

      xdg.configFile."1Password/ssh/agent.toml" = lib.mkIf (cfg.sshAgentConfig != { }) {
        source = (tomlFormat.generate "agent.toml" cfg.sshAgentConfig);
      };
    };
}
