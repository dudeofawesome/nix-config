_final: prev: {
  discord = prev.symlinkJoin {
    inherit (prev.discord) meta passthru;
    name = "discord-without-preload-${prev.discord.version}";
    paths = [ prev.discord ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      wrapProgram $out/opt/Discord/Discord --unset LD_PRELOAD
    '';
  };
}
