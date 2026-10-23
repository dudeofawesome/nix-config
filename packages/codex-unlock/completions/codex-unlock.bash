_codex_unlock() {
  COMPREPLY=()
  [[ $COMP_CWORD == 1 ]] || return 0
  local session
  while IFS= read -r session; do
    [[ $session == "${COMP_WORDS[COMP_CWORD]}"* ]] && COMPREPLY+=("$session")
  done < <(codex-unlock --list)
  return 0
}
complete -F _codex_unlock codex-unlock
