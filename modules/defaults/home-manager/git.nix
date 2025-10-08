{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
with pkgs.stdenv.targetPlatform;
let
  doa-lib = import ../../../lib;

  has_1password =
    config.programs._1password-cli.enable
    || config.programs._1password-gui.enable
    || (isLinux && (osConfig.programs._1password.enable || osConfig.programs._1password-gui.enable))
    || (isDarwin && doa-lib.cask-installed "1password");
in
{
  programs = {
    git = {
      enable = true;

      ignores = [
        ".DS_Store"
      ];

      signing.signByDefault = true;

      extraConfig = {
        gpg = {
          format = "ssh";
          ssh = {
            program = lib.mkIf (
              isDarwin && has_1password
            ) "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";

            allowedSignersFile =
              lib.pipe
                {
                  "${config.programs.git.userEmail}" = config.programs.git.signing.key;
                }
                [
                  (lib.mapAttrsToList (name: value: ''${name} namespaces="git" ${value}''))
                  (builtins.concatStringsSep "\n")
                  (pkgs.writeText "git-allowed-signers")
                  builtins.toString
                ];
          };
        };
      };

      aliases = {
        move-commits-to =
          let
            script = pkgs.writeShellScript "git-move-commits-to.sh" ''
              new_branch="$1"
              total_commits="''${2:-1}"

              if [ "$new_branch" == "help" ]; then
                echo "usage: git move-commits-to <new-branch> [<number-of-commits=1>]"
                exit 0
              fi

              if [ -n "$(git status --porcelain=v1 2>/dev/null)" ]; then
                echo "you have uncommitted changes which would be lost" >&2
                exit 1
              elif [ "$new_branch" == "" ]; then
                echo "branch must be specified" >&2
                exit 1
              elif [ "$(git branch --list "$new_branch")" != "" ]; then
                echo "branch $new_branch already exists" >&2
                exit 1
              fi

              git switch -c "$new_branch"
              git switch -
              git reset --hard "HEAD~$total_commits"
              git switch "$new_branch"
            '';
          in
          "!${script}";
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    _1password-shell-plugins = {
      plugins = with pkgs; [
        gh
        glab
      ];
    };
  };
}
