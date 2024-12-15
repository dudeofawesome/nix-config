{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  user = osConfig.users.users.${config.home.username};
in
{
  imports = [ ./starship ];

  programs = {
    fish = {
      enable = true;

      plugins =
        with pkgs.fishPlugins;
        map
          (pkg: {
            name = pkg.name;
            src = pkg.src;
          })
          (
            lib.flatten [
              autopair
              node-binpath
              # node-version
              fishtape_3
              shell-integrations
              editor-updater
              (lib.optional isDarwin osx)
            ]
          );

      preferAbbrs = true;
      shellAbbrs =
        {
          "l" = "ls -lha";
        }
        // (
          if (isLinux) then
            {
              "lblk" = "lsblk --output NAME,SIZE,RM,FSTYPE,FSUSE%,SERIAL,MOUNTPOINT";
            }
          else
            { }
        );

      functions = {
        doa-ssh-keygen = {
          description = ''
            Create SSH ed25519 keys with no passphrase, in ~/.ssh
          '';
          body = ''
            set name "$argv[1]"

            if test -z "$name"
              echo "Usage: doa-ssh-keygen [name]"
              exit 1
            end

            if string match --regex '\/' "$name"
            else
              set name ~/".ssh/$name"
            end

            ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -f "$name"
          '';
        };

        nix-env = {
          description = "Hide nix-env since it shouldn't ever be used";
          body = ''printf "🙅 Don't use nix-env!\n💁 Use `nix shell 'nixpkgs#your_pkg'` instead"'';
        };
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
        lib.mkIf isDarwin ''
          fish_add_path --move --prepend --path ${
            lib.concatMapStringsSep " " dquote (makeBinPathList osConfig.environment.profiles)
          }
          set fish_user_paths $fish_user_paths
        '';
    };

    atuin = {
      enable = true;

      enableFishIntegration = true;
      enableBashIntegration = true;

      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        update_check = false;
        style = "compact";
        # word_jump_mode = "subl";
        filter_mode = "directory";
        filter_mode_shell_up_key_binding = "session";
        search_mode = "fulltext";
        # enter_accept = true;

        keys.scroll_exits = false;

        sync.records = true;
      };
    };
  };

  # nix-darwin won't set an already-existing user's shell
  # https://daiderd.com/nix-darwin/manual/index.html#opt-users.users._name_.shell
  home.activation.setShell = lib.mkIf isDarwin ''
    PATH="/usr/bin:$PATH" $DRY_RUN_CMD sudo chsh -s \
      "${user.shell}${user.shell.shellPath}" \
      "${config.home.username}"
  '';

  xdg.configFile = lib.mkIf (config.programs.fish.enable) {
    dockerFishCompletion = {
      enable = config.programs.docker-client.enable || (isLinux && osConfig.virtualisation.docker.enable);
      target = "fish/completions/docker.fish";
      source = "${pkgs.docker}/share/fish/vendor_completions.d/docker.fish";
    };

    podmanFishCompletion = {
      enable = config.services.podman.enable || (isLinux && osConfig.virtualisation.podman.enable);
      target = "fish/completions/podman.fish";
      source = "${pkgs.podman}/share/fish/vendor_completions.d/podman.fish";
    };
  };
}
