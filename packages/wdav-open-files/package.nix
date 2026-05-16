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

    collect_memory() {
      pid_args=()

      while IFS= read -r pid; do
        if [ -n "$pid" ]; then
          pid_args+=("-pid" "$pid")
        fi
      done < <(
        /bin/ps -axo pid=,comm= |
          awk '
            {
              pid = $1
              $1 = ""
              sub(/^ +/, "")
              command = $0
              split(command, parts, "/")
              basename = parts[length(parts)]

              if (basename ~ /^wdavdaemon$/ \
                || command ~ /Microsoft Defender/ \
                || command ~ /com\.microsoft\.(wdav|mdatp|dlp)/) {
                print pid
              }
            }
          '
      )

      if [ "''${#pid_args[@]}" -eq 0 ]; then
        return
      fi

      /usr/bin/top -l 1 -stats pid,mem -ncols 400 "''${pid_args[@]}" 2>/dev/null |
        awk '
          BEGIN { in_data = 0 }

          /^PID[[:space:]]+MEM/ { in_data = 1; next }

          in_data && NF >= 2 {
            val = $2
            unit = substr(val, length(val), 1)
            num = substr(val, 1, length(val) - 1) + 0

            if (unit == "K") kb = num
            else if (unit == "M") kb = num * 1024
            else if (unit == "G") kb = num * 1024 * 1024
            else if (unit == "T") kb = num * 1024 * 1024 * 1024
            else kb = val + 0

            total += kb
          }

          END {
            if (total > 0) {
              printf "defender\t%d\n", total
            }
          }
        '
    }

    update_peak_data() {
      if [ -z "$memory_info" ]; then
        return
      fi

      peak_data="$(
        {
          if [ -n "$peak_data" ]; then
            printf '%s\n' "$peak_data"
          fi
          printf '%s\n' "$memory_info"
        } |
          awk '
            NF {
              if ($2 + 0 > peak[$1] + 0) {
                peak[$1] = $2
              }
            }

            END {
              for (b in peak) {
                printf "%s\t%s\n", b, peak[b]
              }
            }
          ' |
          sort
      )"
    }

    render_memory() {
      info="$1"
      peak="$2"
      use_peak="$3"

      if [ -z "$info" ]; then
        return
      fi

      printf '%s\n' "$info" |
        awk -v peak_data="$peak" -v use_peak="$use_peak" '
          BEGIN {
            if (use_peak == "true") {
              n = split(peak_data, lines, "\n")

              for (i = 1; i <= n; i++) {
                if (lines[i] == "") continue
                split(lines[i], parts, "\t")
                total_peak += parts[2]
              }
            } else {
              use_peak = ""
            }
          }

          NF {
            total_current += $2
            count++
          }

          END {
            if (count == 0) exit

            if (use_peak) {
              printf "memory: %.1f MB (peak %.1f MB)\n", total_current/1024, total_peak/1024
            } else {
              printf "memory: %.1f MB\n", total_current/1024
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
      memory_info="$(collect_memory)"

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
      display_count="''${5:-$(printf '%s\n' "$display_paths" | awk 'NF { count++ } END { print count + 0 }')}"
      output_file_path="''${6:-}"

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

      render_memory "$memory_info" "''${peak_data:-}" "''${track_peak:-}"

      if [ -n "$output_file_path" ]; then
        printf 'output file: %s\n' "$output_file_path"
      fi

      printf '\n'

      if [ "$lsof_status" -ne 0 ]; then
        printf 'Warning: lsof returned partial data; run with sudo for full results.\n\n'
      fi

      if [ "$display_count" -eq 0 ]; then
        printf 'No non-internal open files found.\n'
      elif [ -n "$max_paths" ]; then
        printf '%s\n' "$display_paths" |
          awk -v max="$max_paths" -v width="$max_width" -v total="$display_count" '
            NF {
              seen++

              if (seen <= max) {
                line = $0
                limit = width - 1

                if (limit > 4 && length(line) > limit) {
                  line = substr(line, 1, limit - 3) "..."
                }

                print line
              }
            }

            END {
              if (total > seen) {
                printf "... %d more paths not shown.\n", total - seen
              } else if (seen > max) {
                printf "... %d more paths not shown.\n", seen - max
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

    write_current_output() {
      if [ -z "$output_file" ]; then
        return
      fi

      printf '%s\n' "$paths" > "$output_file"
    }

    append_new_output() {
      if [ -z "$output_file" ]; then
        return
      fi

      printf '%s\n' "$paths" |
        awk -v seen_file="$seen_file" -v output_file="$output_file" '
          BEGIN {
            while ((getline line < seen_file) > 0) {
              seen[line] = 1
            }

            close(seen_file)
          }

          NF && !seen[$0] {
            print $0 >> output_file
            print $0 >> seen_file
            seen[$0] = 1
          }
        '
    }

    output_count() {
      awk 'NF { count++ } END { print count + 0 }' "$output_file"
    }

    recent_output() {
      awk -v max="$1" '
        NF {
          lines[++count] = $0
        }

        END {
          start = count - max + 1

          if (start < 1) {
            start = 1
          }

          for (i = start; i <= count; i++) {
            print lines[i]
          }
        }
      ' "$output_file"
    }

    prepare_output_file() {
      /bin/chmod 0644 "$output_file"

      if [ -n "''${SUDO_UID:-}" ] && [ -n "''${SUDO_GID:-}" ]; then
        /usr/sbin/chown "$SUDO_UID:$SUDO_GID" "$output_file" || true
      fi
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
        output_file=""
        seen_file=""
        peak_data=""
        track_peak=true

        cleanup() {
          if [ -n "$old_stty" ]; then
            stty "$old_stty"
          fi

          if [ -t 1 ]; then
            printf '\033[?25h\033[?1049l'
          else
            printf '\033[?25h'
          fi

          if [ -n "$seen_file" ]; then
            rm -f "$seen_file"
          fi

          if [ -n "$output_file" ]; then
            printf '\nwdav-open-files output saved to %s\n' "$output_file"
          fi
        }

        if [ -t 0 ]; then
          old_stty="$(stty -g)"
          stty -icanon -echo min 0 time 0
        fi

        trap cleanup EXIT
        trap 'exit' INT TERM

        output_file="$(mktemp "''${TMPDIR:-/tmp}/wdav-open-files.XXXXXX")"
        prepare_output_file

        if [ "$append_new" = true ]; then
          seen_file="$(mktemp "''${TMPDIR:-/tmp}/wdav-open-files-seen.XXXXXX")"
        fi

        if [ -t 1 ]; then
          printf '\033[?1049h\033[?25l\033[H\033[2J'
        else
          printf '\033[?25l'
        fi

        while true; do
          read -r rows cols < <(terminal_size)

          collect_snapshot
          update_peak_data

          # Fixed lines around the path list:
          #   timestamp, PIDs, label, memory, output file, blank,
          #   "more not shown" sentinel, blank, "Refreshing..." footer
          reserve=9

          if [ "$lsof_status" -ne 0 ]; then
            reserve=$((reserve + 2))
          fi

          if [ "$append_new" = true ]; then
            reserve=$((reserve + 1))
          fi

          max_paths="$(
            awk -v rows="$rows" -v reserve="$reserve" \
              'BEGIN { max = rows - reserve; print (max > 1 ? max : 1) }'
          )"

          if [ "$append_new" = true ]; then
            append_new_output
            display_total="$(output_count)"
            display_paths="$(recent_output "$max_paths")"
            display_label=$'opened files \033[3mseen\033[23m this run'
          else
            write_current_output
            display_total="$(output_count)"
            display_paths="$(recent_output "$max_paths")"
            display_label="filtered open files"
          fi

          frame="$(
            if [ "$append_new" = true ]; then
              render_snapshot "$max_paths" "$cols" "$display_paths" "$display_label" "$display_total" "$output_file"
            else
              render_snapshot "$max_paths" "$cols" "$display_paths" "$display_label" "$display_total" "$output_file"
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
