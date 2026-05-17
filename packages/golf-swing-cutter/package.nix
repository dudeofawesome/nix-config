{
  lib,
  stdenvNoCC,
  makeWrapper,
  fish,
  ffmpeg,
  gawk,
  coreutils,
  gnused,
  ...
}:

stdenvNoCC.mkDerivation {
  pname = "golf-swing-cutter";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    fish
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 golf-swing-cutter.fish "$out/bin/golf-swing-cutter"
    patchShebangs "$out/bin/golf-swing-cutter"
    wrapProgram "$out/bin/golf-swing-cutter" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          ffmpeg
          gawk
          gnused
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Cut golf footage into clips around detected swing impacts";
    mainProgram = "golf-swing-cutter";
    platforms = lib.platforms.unix;
  };
}
