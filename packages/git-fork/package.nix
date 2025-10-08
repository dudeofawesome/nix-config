{
  lib,
  fetchurl,
  undmg,
  stdenv,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-fork";
  version = "2.57.1";
  src = fetchurl {
    url = "https://cdn.fork.dev/mac/Fork-${finalAttrs.version}.dmg";
    hash = "sha256-hIrR655lCKBDkZS6cF7BD+WMvX13T9180rpAfUYc8YA=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/"
    mv Fork.app "$out/Applications/"
    ln -s "$out/Applications/Fork.app/Contents/MacOS/Fork" "$out/bin/fork"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Git client";
    homepage = "https://git-fork.com";
    license = licenses.unfree;
    # maintainers = with maintainers; [ dudeofawesome ];
    platforms = platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "fork";
  };
})
