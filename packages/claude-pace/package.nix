{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  git,
  jq,
  perl,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-pace";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "Astro-Han";
    repo = "claude-pace";
    rev = "v${finalAttrs.version}";
    hash = "sha256-4d8W6ESfXoPL+MA2qx/rkN10TJb0OnPqNwyd1ETxRoc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 claude-pace.sh "$out/bin/claude-pace"

    if [ -d .claude-plugin ]; then
      mkdir -p "$out/share/claude-pace"
      cp -R .claude-plugin "$out/share/claude-pace/"
    fi

    if [ -d commands ]; then
      mkdir -p "$out/share/claude-pace"
      cp -R commands "$out/share/claude-pace/"
    fi

    wrapProgram "$out/bin/claude-pace" \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          git
          jq
          perl
        ]
      }

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code statusline and rate limit tracker with pace-aware quota monitoring";
    homepage = "https://github.com/Astro-Han/claude-pace";
    license = licenses.mit;
    mainProgram = "claude-pace";
    platforms = platforms.unix;
  };
})
