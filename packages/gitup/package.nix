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
  version = "1.5.0";
  src = fetchurl {
    url = "https://github.com/git-up/GitUp/releases/download/v${finalAttrs.version}/GitUp.zip";
    hash = "sha256-Xh2RXtUzM04WkfnAHrPLnS5fRZ+3qiYxtxEg/1mtWFs=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{bin,Applications}
    mv GitUp.app "$out/Applications/"
    ln -s "$out/Applications/GitUp.app/Contents/SharedSupport/gitup" "$out/bin/gitup"

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
    mainProgram = "gitup";
  };
})
