{
  lib,
  stdenv,
  fetchurl,
  undmg,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "finicky";
  version = "4.2.2";
  src = fetchurl {
    url = "https://github.com/johnste/finicky/releases/download/v${finalAttrs.version}/Finicky.dmg";
    hash = "sha256-XwAgeCyQddJ0EdYIPXvoZjiR4xRshur60RjESswSII8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{bin,Applications}
    mv Finicky.app "$out/Applications/"
    ln -s "$out/Applications/Finicky.app/Contents/MacOS/Finicky" "$out/bin/finicky"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Always open the right browser";
    longDescription = "A macOS app for customizing which browser to start";
    homepage = "https://github.com/johnste/finicky";
    license = lib.licenses.mit;
    # maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "finicky";
  };
})
