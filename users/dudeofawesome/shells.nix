{ pkgs, lib, osConfig, dotfiles, ... }: {
  programs = {
    fish = {
      enable = true;

      plugins = with pkgs.fishPlugins;
        map
          (pkg: {
            name = pkg.name;
            src = pkg.src;
          }) [
          tide
          autopair
          node-binpath
          # node-version
          fishtape_3
          shell-integrations
          doa-tide-settings
        ];

      shellAbbrs = {
        "l" = "ls -lha";
        "lblk" = "lsblk --output NAME,SIZE,RM,FSTYPE,FSUSE%,SERIAL,MOUNTPOINT";
        "k" = "kubectl";
      };

      functions = {
        _tide_item_gcloud = builtins.readFile "${dotfiles}/home/.config/fish/functions/_tide_item_gcloud.fish";
      };

      # HACK: fix fish PATH: https://github.com/LnL7/nix-darwin/issues/122
      loginShellInit =
        let
          # This naive quoting is good enough in this case. There shouldn't be any
          # double quotes in the input string, and it needs to be double quoted in case
          # it contains a space (which is unlikely!)
          dquote = str: "\"" + str + "\"";

          makeBinPathList = map (path: path + "/bin");
        in
        ''
          fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)}
          set fish_user_paths $fish_user_paths
        '';
    };

    atuin = {
      enable = true;

      enableFishIntegration = true;
      enableBashIntegration = true;

      settings = {
        sync_address = "https://atuin.orleans.io";
        style = "compact";
        # word_jump_mode = "subl";
      };
    };
  };

  # Since it's not possible to declare default shell, run this command after build
  home.activation = {
    setShell = ''PATH="/usr/bin:$PATH" $DRY_RUN_CMD sudo chsh -s ${pkgs.fish}/bin/fish $(whoami)'';
  };
}
