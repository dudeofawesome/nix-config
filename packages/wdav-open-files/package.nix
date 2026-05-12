{
  lib,
  writeShellApplication,
  gawk,
  less,
  lsof,
  ...
}:

writeShellApplication {
  name = "wdav-open-files";

  runtimeInputs = [
    gawk
    less
    lsof
  ];

  text = ''
    usage() {
      cat <<'USAGE'
    Usage: wdav-open-files [--once] [--pager] [--append-new] [--interval SECONDS] [--help]

    Show non-internal files currently opened by wdavdaemon_* processes.

    Options:
      --once              Print one snapshot and exit.
      --pager             Open one snapshot in ''${PAGER:-less}.
      --append-new        In live mode, keep paths after they first appear.
      --interval SECONDS  Refresh interval for live mode. Default: 5.
      --help              Show this help.
    USAGE
    }

    interval=5
    mode=live
    append_new=false

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --once)
          mode=once
          shift
          ;;
        --pager)
          mode=pager
          shift
          ;;
        --append-new|--history)
          append_new=true
          shift
          ;;
        --interval)
          if [ "$#" -lt 2 ]; then
            echo "wdav-open-files: --interval requires a value" >&2
            exit 2
          fi

          interval="$2"
          case "$interval" in
            ""|*[!0-9.]*)
              echo "wdav-open-files: interval must be a positive number" >&2
              exit 2
              ;;
          esac

          if ! awk 'BEGIN { exit !(ARGV[1] > 0) }' "$interval"; then
            echo "wdav-open-files: interval must be greater than zero" >&2
            exit 2
          fi

          shift 2
          ;;
        --help|-h)
          usage
          exit 0
          ;;
        *)
          echo "wdav-open-files: unknown option: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    done

    find_wdav_pids() {
      /bin/ps -axo pid=,comm= |
        awk '
          {
            pid = $1
            $1 = ""
            sub(/^ +/, "")
            command = $0
            split(command, parts, "/")
            basename = parts[length(parts)]

            if (basename ~ /^wdavdaemon_/) {
              print pid
            }
          }
        '
    }

    filter_paths() {
      awk '
        /^n/ {
          path = substr($0, 2)

          if (path == "" || path == "/dev/null") next
          if (path !~ "^/") next
          if (path ~ "^/Applications/Microsoft Defender([^/]*)?\\.app(/|$)") next
          if (path ~ "^/Library/Application Support/Microsoft/(Defender|DLP|mdatp|wdav|Windows Defender)(/|$)") next
          if (path ~ "^/Library/Caches/com\\.microsoft\\.(mdatp|wdav|wdavdaemon)(/|$)") next
          if (path ~ "^/Library/Logs/Microsoft/(Defender|mdatp)(/|$)") next
          if (path ~ "^/Library/Preferences/com\\.microsoft\\.(mdatp|wdav)") next
          if (path ~ "^/Library/Launch(Agents|Daemons)/com\\.microsoft\\.(mdatp|wdav)") next
          if (path ~ "^/Library/Managed Preferences/.*com\\.microsoft\\.(mdatp|wdav)") next
          if (path ~ "^/private/var/db/com\\.microsoft\\.(mdatp|wdav)(/|$)") next
          if (path ~ "^/private/var/folders/.*/com\\.microsoft\\.(mdatp|wdav|wdavdaemon)(/|$)") next

          print path
        }
      ' |
        sort -u
    }

    terminal_size() {
      size="$(stty size 2>/dev/null || true)"

      rows="$(printf '%s\n' "$size" | awk '{ print $1 }')"
      cols="$(printf '%s\n' "$size" | awk '{ print $2 }')"

      case "$rows" in
        ""|*[!0-9]*)
          rows=24
          ;;
      esac

      case "$cols" in
        ""|*[!0-9]*)
          cols=80
          ;;
      esac

      printf '%s %s\n' "$rows" "$cols"
    }

    collect_snapshot() {
      pids="$(find_wdav_pids | sort -n | tr '\n' ',' | sed 's/,$//')"
      timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
      paths=""
      count=0
      lsof_status=0

      if [ -z "$pids" ]; then
        return
      fi

      lsof_output="$(lsof -nP -w -F n -p "$pids" 2>/dev/null)" || lsof_status="$?"
      paths="$(printf '%s\n' "$lsof_output" | filter_paths)"
      count="$(printf '%s\n' "$paths" | awk 'NF { count++ } END { print count + 0 }')"
    }

    render_snapshot() {
      max_paths="''${1:-}"
      max_width="''${2:-0}"
      display_paths="''${3:-$paths}"
      display_label="''${4:-filtered open files}"
      display_count="$(printf '%s\n' "$display_paths" | awk 'NF { count++ } END { print count + 0 }')"

      printf 'wdav-open-files - %s\n' "$timestamp"

      if [ -z "$pids" ]; then
        printf 'wdavdaemon_* processes: none\n'
        return
      fi

      printf 'wdavdaemon_* PIDs: %s\n' "$pids"
      printf '%s: %s\n' "$display_label" "$display_count"

      if [ "$append_new" = true ] && [ "$display_label" != "filtered open files" ]; then
        printf 'currently active after filters: %s\n' "$count"
      fi

      printf '\n'

      if [ "$lsof_status" -ne 0 ]; then
        printf 'Warning: lsof returned partial data; run with sudo for full results.\n\n'
      fi

      if [ "$display_count" -eq 0 ]; then
        printf 'No non-internal open files found.\n'
      elif [ -n "$max_paths" ]; then
        printf '%s\n' "$display_paths" |
          awk -v max="$max_paths" -v width="$max_width" '
            NF {
              seen++

              if (seen <= max) {
                line = $0

                if (width > 4 && length(line) > width) {
                  line = substr(line, 1, width - 3) "..."
                }

                print line
              }
            }

            END {
              if (seen > max) {
                printf "... %d more paths hidden; use --once or --pager for full list.\n", seen - max
              }
            }
          '
      else
        printf '%s\n' "$display_paths"
      fi
    }

    snapshot() {
      collect_snapshot
      render_snapshot "''${1:-}" "''${2:-}"
    }

    render_live_frame() {
      printf '\033[H'
      printf '%s\n' "$1" |
        awk '{ printf "%s\033[K\n", $0 }'
      printf '\033[J'
    }

    case "$mode" in
      once)
        snapshot
        ;;
      pager)
        snapshot | "''${PAGER:-less}"
        ;;
      live)
        old_stty=""
        history_paths=""

        cleanup() {
          if [ -n "$old_stty" ]; then
            stty "$old_stty"
          fi

          if [ -t 1 ]; then
            printf '\033[?25h\033[?1049l'
          else
            printf '\033[?25h'
          fi
        }

        if [ -t 0 ]; then
          old_stty="$(stty -g)"
          stty -icanon -echo min 0 time 0
        fi

        trap cleanup EXIT
        trap 'exit' INT TERM

        if [ -t 1 ]; then
          printf '\033[?1049h\033[?25l\033[H\033[2J'
        else
          printf '\033[?25l'
        fi

        while true; do
          read -r rows cols < <(terminal_size)
          max_paths="$(awk 'BEGIN { max = ARGV[1] - 9; print (max > 1 ? max : 1) }' "$rows")"

          collect_snapshot

          if [ "$append_new" = true ]; then
            history_paths="$(
              {
                printf '%s\n' "$history_paths"
                printf '%s\n' "$paths"
              } |
                awk 'NF' |
                sort -u
            )"
          fi

          frame="$(
            if [ "$append_new" = true ]; then
              render_snapshot "$max_paths" "$cols" "$history_paths" "opened files seen this run"
            else
              render_snapshot "$max_paths" "$cols"
            fi
            printf '\nRefreshing every %s seconds. Press q to quit.\n' "$interval"
          )"
          render_live_frame "$frame"

          if [ -t 0 ]; then
            remaining="$interval"

            while awk 'BEGIN { exit !(ARGV[1] > 0) }' "$remaining"; do
              if IFS= read -r -s -t 0.1 -n 1 key && [ "$key" = q ]; then
                exit 0
              fi

              remaining="$(awk 'BEGIN { remaining = ARGV[1] - 0.1; print (remaining > 0 ? remaining : 0) }' "$remaining")"
            done
          else
            sleep "$interval"
          fi
        done
        ;;
    esac
  '';

  meta = with lib; {
    description = "Live filtered open-file viewer for Microsoft Defender wdavdaemon processes";
    mainProgram = "wdav-open-files";
    platforms = platforms.darwin;
  };
}
