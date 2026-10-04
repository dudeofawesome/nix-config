_final: prev: {
  discord = prev.symlinkJoin {
    inherit (prev.discord) meta passthru;
    name = "discord-without-preload-${prev.discord.version}";
    paths = [ prev.discord ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      # Wrap public launchers, including aliases, rather than the internal payload.
      for executable in "$out"/bin/*; do
        wrapProgram "$executable" --unset LD_PRELOAD
      done
    '';
  };
}
