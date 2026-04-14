{
  lib,
  fetchurl,
  unzip,
  stdenv,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/stonerl/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-1n9NMe+foFeEmphUC4EM+kLgvGYBnTYFq9CORcaaoG8=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv Thaw.app "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Powerful menu bar manager for macOS";
    homepage = "https://github.com/stonerl/Thaw";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
