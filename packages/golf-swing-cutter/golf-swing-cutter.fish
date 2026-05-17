#!/usr/bin/env fish

set -l out_dir swing-clips
set -l pre_roll 2.5
set -l post_roll 4.0
set -l min_gap 15.0
set -l threshold_db auto
set -l motion_gate 1
set -l motion_threshold 3
set -l motion_delta_threshold 1.5
set -l motion_before 1.0
set -l motion_after 0.35
set -l dry_run 0
set -l force 0

function print_usage
    echo "Usage: golf-swing-cutter [options] VIDEO..."
    echo
    echo "Options:"
    echo "  -o, --out-dir DIR        Output directory (default: swing-clips)"
    echo "      --pre SECONDS        Seconds before impact to keep (default: 2.5)"
    echo "      --post SECONDS       Seconds after impact to keep (default: 4.0)"
    echo "      --min-gap SECONDS    Minimum gap between swings (default: 15.0)"
    echo "      --threshold-db=DB    Peak audio threshold in dB, or auto (default: auto)"
    echo "      --motion-threshold N Minimum visual motion score, 0-100 (default: 3)"
    echo "      --motion-delta N     Minimum motion rise over baseline (default: 1.5)"
    echo "      --motion-before SEC  Motion window before impact (default: 1.0)"
    echo "      --motion-after SEC   Motion window after impact (default: 0.35)"
    echo "      --no-motion-gate     Keep audio hits even without matching video motion"
    echo "      --dry-run            Print planned clips without writing files"
    echo "      --force              Overwrite existing clips"
    echo "  -h, --help               Show this help"
end

function die
    echo "golf-swing-cutter: $argv" >&2
    exit 1
end

function require_command --argument-names name
    command -q "$name"; or die "required command not found: $name"
end

function require_number --argument-names name value
    string match -rq '^[0-9]+([.][0-9]+)?$' -- "$value"; or die "$name must be a non-negative number"
end

function require_threshold --argument-names value
    test "$value" = auto; and return 0
    string match -rq '^-?[0-9]+([.][0-9]+)?$' -- "$value"; or die "--threshold-db must be auto or a number"
end

function measure_motion --argument-names video motion_file
    set -l metadata_file (mktemp -t golf-swing-cutter.motion.XXXXXX)
    set -l log_file (mktemp -t golf-swing-cutter.motion-ffmpeg.XXXXXX)
    set -l filter "fps=12,scale=320:-1,format=gray,tblend=all_mode=difference,blackframe=amount=0:threshold=16,metadata=print:key=lavfi.blackframe.pblack:file=-"

    if not ffmpeg \
            -hide_banner \
            -nostdin \
            -nostats \
            -i "$video" \
            -map 0:v:0 \
            -an \
            -vf "$filter" \
            -f null \
            - >"$metadata_file" 2>"$log_file"
        echo "Failed to analyze video motion for $video" >&2
        sed -n '1,20p' "$log_file" >&2
        rm -f "$metadata_file" "$log_file"
        return 1
    end

    awk \
        '
        /^frame:/ {
          if (match($0, /pts_time:([-0-9.]+)/, parts)) {
            pts_time = parts[1] + 0
          }
        }

        /pblack=/ {
          value = $0
          sub(/^.*pblack=/, "", value)
          sub(/[[:space:]].*$/, "", value)

          printf "%.3f\t%.1f\n", pts_time, 100 - value
        }
        ' "$metadata_file" >"$motion_file"

    set -l awk_status $status
    rm -f "$metadata_file" "$log_file"

    if test $awk_status -ne 0
        echo "Failed to parse video motion analysis for $video" >&2
        return $awk_status
    end

    if not test -s "$motion_file"
        echo "No usable video motion data found in $video" >&2
        return 1
    end
end

function apply_motion_gate --argument-names impact_file motion_file filtered_file stats_file threshold delta_threshold before after min_gap_seconds
    awk \
        -v threshold="$threshold" \
        -v delta_threshold="$delta_threshold" \
        -v before="$before" \
        -v after="$after" \
        -v min_gap="$min_gap_seconds" \
        -v stats_file="$stats_file" \
        '
        function emit_current() {
          if (have_cluster) {
            printf "%s\t%.1f\t%.1f\n", current_line, current_motion, current_delta
            kept++
          }
        }

        FNR == NR {
          motion_count++
          motion_time[motion_count] = $1 + 0
          motion_score[motion_count] = $2 + 0
          next
        }

        {
          impact_time = $1 + 0
          best_score = 0
          found_motion = 0
          baseline_score = 0
          baseline_count = 0

          for (i = 1; i <= motion_count; i++) {
            if (motion_time[i] >= impact_time - before && motion_time[i] <= impact_time + after) {
              found_motion = 1

              if (motion_score[i] > best_score) {
                best_score = motion_score[i]
              }
            }

            if (motion_time[i] >= impact_time - before - 1.8 && motion_time[i] <= impact_time - before - 0.4) {
              baseline_score += motion_score[i]
              baseline_count++
            }
          }

          if (baseline_count > 0) {
            baseline_score = baseline_score / baseline_count
          }

          motion_delta = best_score - baseline_score
          candidates++

          if (found_motion && best_score >= threshold && motion_delta >= delta_threshold) {
            peak_db = $2 + 0

            if (!have_cluster || impact_time - cluster_start_time > min_gap) {
              emit_current()
              have_cluster = 1
              cluster_start_time = impact_time
              current_line = $0
              current_motion = best_score
              current_delta = motion_delta
              current_peak = peak_db
            } else if (best_score > current_motion || (best_score == current_motion && motion_delta > current_delta) || (best_score == current_motion && motion_delta == current_delta && peak_db > current_peak)) {
              current_line = $0
              current_motion = best_score
              current_delta = motion_delta
              current_peak = peak_db
            }
          } else {
            rejected++

            if (best_score > max_rejected_score) {
              max_rejected_score = best_score
            }

            if (motion_delta > max_rejected_delta) {
              max_rejected_delta = motion_delta
            }
          }
        }

        END {
          emit_current()

          printf "candidates=%d\nkept=%d\nrejected=%d\nmax_rejected_motion=%.1f\nmax_rejected_delta=%.1f\nthreshold=%.1f\ndelta_threshold=%.1f\n", candidates, kept, rejected, max_rejected_score, max_rejected_delta, threshold, delta_threshold > stats_file

          if (candidates > 0 && kept == 0) {
            exit 4
          }
        }
        ' "$motion_file" "$impact_file" >"$filtered_file"
end

function dedupe_audio_impacts --argument-names impact_file filtered_file min_gap_seconds
    awk \
        -v min_gap="$min_gap_seconds" \
        '
        function emit_current() {
          if (have_cluster) {
            print current_line
          }
        }

        {
          impact_time = $1 + 0
          peak_db = $2 + 0

          if (!have_cluster || impact_time - cluster_start_time > min_gap) {
            emit_current()
            have_cluster = 1
            cluster_start_time = impact_time
            current_line = $0
            current_peak = peak_db
          } else if (peak_db > current_peak) {
            current_line = $0
            current_peak = peak_db
          }
        }

        END {
          emit_current()
        }
        ' "$impact_file" >"$filtered_file"
end

function detect_swings --argument-names video impact_file threshold
    set -l metadata_file (mktemp -t golf-swing-cutter.metadata.XXXXXX)
    set -l log_file (mktemp -t golf-swing-cutter.ffmpeg.XXXXXX)
    set -l stats_file (mktemp -t golf-swing-cutter.stats.XXXXXX)
    set -l filter "highpass=f=900,lowpass=f=12000,asetnsamples=n=1024:p=1,astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.Peak_level:file=-"

    if not ffmpeg \
            -hide_banner \
            -nostdin \
            -nostats \
            -i "$video" \
            -vn \
            -af "$filter" \
            -f null \
            - >"$metadata_file" 2>"$log_file"
        echo "Failed to analyze audio for $video" >&2
        sed -n '1,20p' "$log_file" >&2
        rm -f "$metadata_file" "$log_file" "$stats_file"
        return 1
    end

    awk \
        -v threshold="$threshold" \
        -v stats_file="$stats_file" \
        '
        function is_number(value) {
          return value ~ /^-?[0-9]+([.][0-9]+)?$/
        }

        BEGIN {
          max_peak = -1000
        }

        /^frame:/ {
          if (match($0, /pts_time:([-0-9.]+)/, parts)) {
            pts_time = parts[1] + 0
          }
        }

        /Peak_level=/ {
          value = $0
          sub(/^.*Peak_level=/, "", value)
          sub(/[[:space:]].*$/, "", value)

          if (value != "-inf" && is_number(value)) {
            count++
            times[count] = pts_time
            peaks[count] = value + 0

            if (peaks[count] > max_peak) {
              max_peak = peaks[count]
            }
          }
        }

        END {
          if (count == 0) {
            exit 3
          }

          if (threshold == "auto") {
            active_threshold = max_peak - 45

            if (active_threshold < -45) {
              active_threshold = -45
            }
          } else {
            active_threshold = threshold + 0
          }

          printf "max_peak=%.2f\nactive_threshold=%.2f\n", max_peak, active_threshold > stats_file

          for (i = 2; i < count; i++) {
            if (peaks[i] >= active_threshold && peaks[i] >= peaks[i - 1] && peaks[i] > peaks[i + 1]) {
              printf "%.3f\t%.2f\n", times[i], peaks[i]
              emitted++
            }
          }

          if (emitted == 0) {
            exit 4
          }
        }
        ' "$metadata_file" >"$impact_file"

    set -l awk_status $status
    set -l max_peak unknown
    set -l active_threshold unknown

    if test -s "$stats_file"
        for stat_line in (string split \n -- (string collect <"$stats_file"))
            set -l stat_parts (string split = -- "$stat_line")

            switch $stat_parts[1]
                case max_peak
                    set max_peak $stat_parts[2]
                case active_threshold
                    set active_threshold $stat_parts[2]
            end
        end
    end

    rm -f "$metadata_file" "$log_file" "$stats_file"

    switch $awk_status
        case 0
            return 0
        case 3
            echo "No usable audio peaks found in $video" >&2
        case 4
            echo "No swings detected in $video. Max audio peak was $max_peak dB; active threshold was $active_threshold dB." >&2
        case '*'
            echo "Failed to parse audio analysis for $video" >&2
    end

    return $awk_status
end

argparse \
    -n golf-swing-cutter \
    'h/help' \
    'o/out-dir=' \
    'pre=' \
    'post=' \
    'min-gap=' \
    'threshold-db=' \
    'motion-threshold=' \
    'motion-delta=' \
    'motion-before=' \
    'motion-after=' \
    'no-motion-gate' \
    'dry-run' \
    'force' \
    -- $argv
or begin
    print_usage >&2
    exit 2
end

if set -q _flag_help
    print_usage
    exit 0
end

if set -q _flag_out_dir
    set out_dir $_flag_out_dir
end

if set -q _flag_pre
    set pre_roll $_flag_pre
end

if set -q _flag_post
    set post_roll $_flag_post
end

if set -q _flag_min_gap
    set min_gap $_flag_min_gap
end

if set -q _flag_threshold_db
    set threshold_db $_flag_threshold_db
end

if set -q _flag_motion_threshold
    set motion_threshold $_flag_motion_threshold
end

if set -q _flag_motion_delta
    set motion_delta_threshold $_flag_motion_delta
end

if set -q _flag_motion_before
    set motion_before $_flag_motion_before
end

if set -q _flag_motion_after
    set motion_after $_flag_motion_after
end

if set -q _flag_no_motion_gate
    set motion_gate 0
end

if set -q _flag_dry_run
    set dry_run 1
end

if set -q _flag_force
    set force 1
end

require_number --pre "$pre_roll"
require_number --post "$post_roll"
require_number --min-gap "$min_gap"
require_number --motion-threshold "$motion_threshold"
require_number --motion-delta "$motion_delta_threshold"
require_number --motion-before "$motion_before"
require_number --motion-after "$motion_after"
require_threshold "$threshold_db"

test (count $argv) -gt 0; or begin
    print_usage >&2
    exit 2
end

require_command awk
require_command basename
require_command ffmpeg
require_command mktemp
require_command sed

set -l clip_duration (awk -v pre="$pre_roll" -v post="$post_roll" 'BEGIN { printf "%.3f", pre + post }')
set -l total_clips 0

for video in $argv
    test -f "$video"; or die "video file does not exist: $video"

    set -l filename (basename -- "$video")
    set -l stem (string replace -r '\.[^.]*$' '' -- "$filename")
    set -l video_out_dir "$out_dir/$stem"
    set -l impact_file (mktemp -t golf-swing-cutter.impacts.XXXXXX)

    echo "Analyzing audio for $video" >&2
    detect_swings "$video" "$impact_file" "$threshold_db"; or begin
        rm -f "$impact_file"
        continue
    end

    if test $motion_gate -eq 1
        set -l motion_file (mktemp -t golf-swing-cutter.motion-scores.XXXXXX)
        set -l filtered_impact_file (mktemp -t golf-swing-cutter.motion-filtered.XXXXXX)
        set -l motion_stats_file (mktemp -t golf-swing-cutter.motion-stats.XXXXXX)

        echo "Checking video motion near audio hits for $video" >&2
        measure_motion "$video" "$motion_file"; or begin
            rm -f "$impact_file" "$motion_file" "$filtered_impact_file" "$motion_stats_file"
            continue
        end

        apply_motion_gate \
            "$impact_file" \
            "$motion_file" \
            "$filtered_impact_file" \
            "$motion_stats_file" \
            "$motion_threshold" \
            "$motion_delta_threshold" \
            "$motion_before" \
            "$motion_after" \
            "$min_gap"

        set -l motion_gate_status $status
        set -l candidates unknown
        set -l kept unknown
        set -l rejected unknown
        set -l max_rejected_motion unknown
        set -l max_rejected_delta unknown

        if test -s "$motion_stats_file"
            for stat_line in (string split \n -- (string collect <"$motion_stats_file"))
                set -l stat_parts (string split = -- "$stat_line")

                switch $stat_parts[1]
                    case candidates
                        set candidates $stat_parts[2]
                    case kept
                        set kept $stat_parts[2]
                    case rejected
                        set rejected $stat_parts[2]
                    case max_rejected_motion
                        set max_rejected_motion $stat_parts[2]
                    case max_rejected_delta
                        set max_rejected_delta $stat_parts[2]
                end
            end
        end

        rm -f "$impact_file" "$motion_file" "$motion_stats_file"
        set impact_file "$filtered_impact_file"

        if test $motion_gate_status -ne 0
            if test $motion_gate_status -eq 4
                echo "No swings passed the motion gate in $video. Highest rejected motion score was $max_rejected_motion%; highest rejected motion delta was $max_rejected_delta%; thresholds were $motion_threshold% motion and $motion_delta_threshold% delta." >&2
            else
                echo "Failed to apply video motion gate to $video" >&2
            end

            rm -f "$impact_file"
            continue
        end

        if test "$rejected" != 0
            echo "Motion gate kept $kept of $candidates audio hit(s), rejected $rejected." >&2
        end
    else
        set -l filtered_impact_file (mktemp -t golf-swing-cutter.audio-filtered.XXXXXX)
        dedupe_audio_impacts "$impact_file" "$filtered_impact_file" "$min_gap"
        rm -f "$impact_file"
        set impact_file "$filtered_impact_file"
    end

    set -l impacts (string split \n -- (string collect <"$impact_file"))
    rm -f "$impact_file"

    if test $dry_run -eq 0
        mkdir -p "$video_out_dir"
    end

    set -l index 1
    for impact_line in $impacts
        test -n "$impact_line"; or continue

        set -l fields (string split \t -- "$impact_line")
        set -l impact_time $fields[1]
        set -l peak_db $fields[2]
        set -l motion_score off
        set -l motion_delta off
        if test (count $fields) -ge 3
            set motion_score $fields[3]
        end
        if test (count $fields) -ge 4
            set motion_delta $fields[4]
        end
        set -l start_time (awk -v impact="$impact_time" -v pre="$pre_roll" 'BEGIN { start = impact - pre; if (start < 0) start = 0; printf "%.3f", start }')
        set -l clip_number (printf "%03d" "$index")
        set -l output "$video_out_dir/$stem-swing-$clip_number.mp4"

        if test $dry_run -eq 1
            printf "%s\timpact=%ss\tpeak=%sdB\tmotion=%s%%\tmotion-delta=%s%%\tstart=%ss\tduration=%ss\n" "$output" "$impact_time" "$peak_db" "$motion_score" "$motion_delta" "$start_time" "$clip_duration"
        else
            set -l overwrite -n
            if test $force -eq 1
                set overwrite -y
            end

            ffmpeg \
                -hide_banner \
                -nostdin \
                -loglevel error \
                $overwrite \
                -ss "$start_time" \
                -i "$video" \
                -t "$clip_duration" \
                -map 0:v:0 \
                -map 0:a:0? \
                -map_metadata 0 \
                -fps_mode passthrough \
                -c:v libx264 \
                -preset veryfast \
                -crf 18 \
                -c:a aac \
                -b:a 160k \
                -movflags +faststart \
                "$output"
            or die "failed to write clip: $output"

            echo "Wrote $output" >&2
        end

        set total_clips (math "$total_clips + 1")
        set index (math "$index + 1")
    end
end

echo "Detected $total_clips swing clip(s)." >&2
