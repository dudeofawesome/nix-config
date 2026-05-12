{
  lib,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  recordPrompt = pkgs.writeShellApplication {
    name = "claude-record-prompt";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      state_dir="''${CLAUDE_STATE_DIR:-$HOME/.claude/state}"
      mkdir -p "$state_dir"
      session_id=$(jq -r '.session_id // "default"' <<<"$(cat)")
      date +%s >"$state_dir/last-prompt-$session_id"
    '';
  };

  notifyIfAway = pkgs.writeShellApplication {
    name = "claude-notify-if-away";
    runtimeInputs = [ pkgs.jq ];
    text = ''
      state_dir="''${CLAUDE_STATE_DIR:-$HOME/.claude/state}"
      threshold="''${CLAUDE_NOTIFY_THRESHOLD:-30}"
      default_message="''${1:-Claude Code needs you}"

      input=$(cat)
      session_id=$(jq -r '.session_id // "default"' <<<"$input")
      message=$(jq -r --arg d "$default_message" '.message // $d' <<<"$input")

      terminals=(
        com.googlecode.iterm2
        com.apple.Terminal
        com.mitchellh.ghostty
        net.kovidgoyal.kitty
        com.github.wez.wezterm
        com.microsoft.VSCode
        com.microsoft.VSCodeInsiders
        com.todesktop.230313mzl4w4u92
        dev.zed.Zed
      )

      frontmost=$(/usr/bin/osascript \
        -e 'tell application "System Events" to get bundle identifier of first process whose frontmost is true' \
        2>/dev/null || true)

      should_notify=1
      if [ -n "$frontmost" ]; then
        for term in "''${terminals[@]}"; do
          if [ "$frontmost" = "$term" ]; then
            should_notify=0
            break
          fi
        done
      else
        stamp_file="$state_dir/last-prompt-$session_id"
        if [ -r "$stamp_file" ]; then
          last=$(cat "$stamp_file")
          now=$(date +%s)
          elapsed=$((now - last))
          if [ "$elapsed" -lt "$threshold" ]; then
            should_notify=0
          fi
        fi
      fi

      if [ "$should_notify" -eq 1 ]; then
        escaped=$(printf '%s' "$message" | sed 's/["\\]/\\&/g')
        /usr/bin/osascript \
          -e "display notification \"$escaped\" with title \"Claude Code\" sound name \"Glass\""
      fi
    '';
  };
in
{
  programs = {
    mcp = {
      enable = true;
      servers = {
        kubernetes.command = lib.getExe pkgs.kubernetes-mcp-server;
      };
    };

    claude-code = {
      context = ./user-memory.md;
      skills = {
        jira-defaults = ./skills/jira-defaults.md;
        grill-me = ./skills/grill-me.md;
      };

      settings.hooks = lib.mkIf isDarwin {
        UserPromptSubmit = [
          {
            hooks = [
              {
                type = "command";
                command = lib.getExe recordPrompt;
              }
            ];
          }
        ];
        Notification = [
          {
            hooks = [
              {
                type = "command";
                command = "${lib.getExe notifyIfAway} 'Claude Code is waiting for input'";
              }
            ];
          }
        ];
        Stop = [
          {
            hooks = [
              {
                type = "command";
                command = "${lib.getExe notifyIfAway} 'Claude Code finished'";
              }
            ];
          }
        ];
      };
    };

    codex = {
      enable = true;
      package =
        let
          codexOnePasswordEnv = {
            # Match each environment variable to a 1Password secret reference.
            GITHUB_PAT = "op://Private/Github PAT - dudeofawesome/credential";
            HOME_ASSISTANT_TOKEN = "op://Private/poosdxwzsqeuvybjjasl25hp5m/credential";
          };

          codexPackage =
            let
              op = lib.getExe config.programs._1password-cli.package;
              wrappedCodex = pkgs.writeShellScript "codex" ''
                set -euo pipefail

                ${lib.concatLines (
                  lib.mapAttrsToList (
                    name: reference: ''export ${name}="$(${op} read ${lib.escapeShellArg reference})"''
                  ) codexOnePasswordEnv
                )}

                exec ${lib.getExe pkgs-unstable.codex} "$@"
              '';
            in
            pkgs.symlinkJoin {
              name = "codex-with-1password-env";
              paths = [ pkgs-unstable.codex ];
              postBuild = ''
                rm "$out/bin/codex"
                ln -s ${wrappedCodex} "$out/bin/codex"
              '';
            };
        in
        codexPackage;

      context = ./user-memory.md;

      skills = {
        grill-me = ./skills/grill-me.md;
      };

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.codex.custom-instructions
      settings.mcp_servers = {
        github = {
          url = "https://api.githubcopilot.com/mcp/";
          bearer_token_env_var = "GITHUB_PAT";
        };
        home-assistant = {
          url = "https://hass.red.orleans.io/api/mcp";
          bearer_token_env_var = "HOME_ASSISTANT_TOKEN";
        };
      };
    };
  };
}
