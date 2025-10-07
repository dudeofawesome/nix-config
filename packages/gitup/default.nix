{
  lib,
  fetchurl,
  unzip,
  stdenv,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gitup";
  version = "1.4.3";
  src = fetchurl {
    url = "https://github.com/git-up/GitUp/releases/download/v${finalAttrs.version}/GitUp.zip";
    hash = "sha256-8PGJba56F+P1H2hyzFenkGGrP0dpLWS1qCFs+23dtNw=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/"
    mv GitUp.app "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "The Git interface you've been missing all your life has finally arrived.";
    homepage = "https://gitup.co";
    license = licenses.gpl3;
    # maintainers = with maintainers; [ dudeofawesome ];
    platforms = platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
