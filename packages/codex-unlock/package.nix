{
  lib,
  writeShellApplication,
  installShellFiles,
  jq,
  coreutils,
  ...
}:
writeShellApplication {
  name = "codex-unlock";
  runtimeInputs = [
    jq
    coreutils
  ];
  text = builtins.readFile ./codex-unlock.sh;
  derivationArgs = {
    nativeBuildInputs = [ installShellFiles ];
    postCheck = ''
      installShellCompletion --cmd codex-unlock \
        --bash ${./completions/codex-unlock.bash} \
        --zsh ${./completions/_codex-unlock} \
        --fish ${./completions/codex-unlock.fish}
    '';
  };
  meta = {
    description = "Clear Codex thread writer locks by session name or UUID";
    mainProgram = "codex-unlock";
    platforms = lib.platforms.unix;
  };
}
