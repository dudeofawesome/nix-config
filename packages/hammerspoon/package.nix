{
  lib,
  fetchurl,
  stdenv,
  unzip,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hammerspoon";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/Hammerspoon/hammerspoon/releases/download/${finalAttrs.version}/Hammerspoon-${finalAttrs.version}.zip";
    hash = "sha256-EbsckPr1Qn83x71P5+q5d0rkPh1csCDFswiNrDKEnvo=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{bin,Applications}
    mv Hammerspoon.app "$out/Applications/"
    ln -s "$out/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon" "$out/bin/hammerspoon"
    ln -s "$out/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs" "$out/bin/hs"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Staggeringly powerful macOS desktop automation with Lua";
    homepage = "https://www.hammerspoon.org";
    changelog = "https://github.com/Hammerspoon/hammerspoon/releases";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "hammerspoon";
  };
})
