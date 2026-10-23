#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == --help || ${1:-} == -h || $# != 1 ]]; then
  cat <<'EOF'
Usage: codex-unlock <session-name-or-uuid>
       codex-unlock --list

Remove a Codex thread writer lock. Close the affected session first:
unlinking its lock does not stop a running writer.
Uses CODEX_HOME, defaulting to ~/.codex.
EOF
  [[ $# == 1 ]]
  exit
fi

codex_home=${CODEX_HOME:-$HOME/.codex}
index=$codex_home/session_index.jsonl
[[ -f $index ]] || index=/dev/null
shopt -s nullglob
ids=()
for lock in "$codex_home"/thread-writer-locks/*.lock; do
  id=${lock##*/}
  id=${id%.lock}
  [[ $id =~ ^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$ ]] && ids+=("$id")
done

# The append-only index can contain several names for the same thread.
sessions=$(jq -n --slurpfile index "$index" --args '
  ($index | reduce .[] as $s ({}; .[$s.id] = $s.thread_name)) as $names
  | $ARGS.positional | map({id: ., name: ($names[.] // .)})
' "${ids[@]}")

if [[ $1 == --list ]]; then
  jq -r '[.[] | .name, .id] | unique[]' <<< "$sessions"
  exit
fi

matches=$(jq --arg session "$1" '
  [.[] | select(.id == $session or .name == $session)]
' <<< "$sessions")
case $(jq length <<< "$matches") in
  0) echo "No lock found for session: $1" >&2; exit 1 ;;
  1) ;;
  *) echo "Ambiguous session name; use a UUID:" >&2
     jq -r '.[].id' <<< "$matches" >&2
     exit 1 ;;
esac
id=$(jq -r '.[0].id' <<< "$matches")
rm -- "$codex_home/thread-writer-locks/$id.lock"
printf 'Cleared lock for %s\n' "$id"
